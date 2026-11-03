---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Shutdown Order And Jobs With Sidecars

A helper container is only useful if it outlives the work it helps. A log shipper that stops before the application loses the last log lines. A proxy that stops first breaks the final requests. The opposite problem exists in a Job: a helper that never stops keeps the Job from finishing. Native sidecars solve both, because the kubelet controls when they stop.

This part first shows the Job that never completes, then converts it, and then reads the shutdown order, the grace period and the `preStop` hook.

## A Job that never completes

A Job is a workload that runs Pods until a set number of them succeed. The Job controller, a loop inside the controller manager, watches the phase of the Job's Pods. A Pod reaches the phase `Succeeded` only when every container in it has terminated successfully. The playground has the Job `stuck-report`. Its Pod has two ordinary containers: `report` writes three lines and exits, and `log-shipper` follows the file with `tail -F` and never exits.

<!-- astrona:playground:renew -->

Look at the Job and its Pod about twenty seconds after the playground started:

```sh
kubectl -n starfleet get job stuck-report
kubectl -n starfleet get pods -l job-name=stuck-report
```

The Job shows `0/1` completions. The Pod shows `1/2` ready containers and the status `Running`. The `report` container ended with exit code 0, and the `log-shipper` container still runs. Because one container is still running, the Pod never reaches `Succeeded`, and the Job controller keeps waiting. The Job stays active until the cluster removes it.

Setting `activeDeadlineSeconds` on the Job would end it, but the Job would then be marked failed, which is wrong for work that succeeded. Adding a signal from the main container to the shipper needs a shared process namespace and extra code. A native sidecar needs neither.

## The same Job with a native sidecar

The only change is the place of the shipper. It moves from `containers` to `initContainers` and gets `restartPolicy: Always`. The kubelet then knows that the shipper serves the main container and does not decide whether the Pod is done.

Save this as `job-finished-report.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: finished-report
  namespace: starfleet
spec:
  backoffLimit: 0
  template:
    spec:
      restartPolicy: Never
      terminationGracePeriodSeconds: 10
      initContainers:
        - name: log-shipper
          image: docker.io/library/busybox:1.37.0
          restartPolicy: Always
          command: ["sh", "-c"]
          args:
            - |
              trap 'exit 0' TERM
              tail -n +1 -F /logs/report.log | while IFS= read -r line; do
                echo "shipped: $line"
              done &
              wait $!
          volumeMounts:
            - name: logs
              mountPath: /logs
              readOnly: true
      containers:
        - name: report
          image: docker.io/library/busybox:1.37.0
          command: ["sh", "-c"]
          args:
            - |
              for n in 1 2 3; do echo "reading $n" >> /logs/report.log; sleep 2; done
              echo "report finished"
          volumeMounts:
            - name: logs
              mountPath: /logs
      volumes:
        - name: logs
          emptyDir: {}
```

Apply it:

```sh
kubectl apply -f job-finished-report.yaml
```

Then check the result. The Job completes after the `report` container exits:

```sh
kubectl -n starfleet wait --for=condition=Complete job/finished-report --timeout=120s
kubectl -n starfleet logs job/finished-report -c log-shipper
```

The Job shows `1/1` completions. The shipper logs contain `shipped: reading 1`, `shipped: reading 2` and `shipped: reading 3`. When `report` exited, the kubelet saw that no application container was left, sent SIGTERM to the sidecar and marked the Pod `Succeeded`. The Job controller then counted one success.

## Termination in reverse order

When a Pod is deleted or its application containers finish, the kubelet stops the containers in a fixed order. It waits until every application container has fully stopped. Then it stops the sidecars in the reverse of their order in `initContainers`. The last sidecar to start is the first to stop. This keeps a sidecar that another sidecar depends on alive until the dependent one has gone.

For each container the kubelet runs the `preStop` hook first, if one exists. A `preStop` hook is a command or HTTP request in the `lifecycle` field that runs before the container receives SIGTERM. Then the container runtime sends SIGTERM, and if the container has not exited when the grace period ends, it sends SIGKILL.

Save this as `job-ordered-shutdown.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: ordered-shutdown
  namespace: starfleet
spec:
  backoffLimit: 0
  template:
    spec:
      restartPolicy: Never
      terminationGracePeriodSeconds: 15
      initContainers:
        - name: first
          image: docker.io/library/busybox:1.37.0
          restartPolicy: Always
          command: ["sh", "-c"]
          args:
            - |
              trap 'echo "first: received SIGTERM"; exit 0' TERM
              echo "first: started"
              while true; do sleep 1; done
        - name: second
          image: docker.io/library/busybox:1.37.0
          restartPolicy: Always
          command: ["sh", "-c"]
          args:
            - |
              trap 'echo "second: received SIGTERM"; exit 0' TERM
              echo "second: started"
              while true; do sleep 1; done
          lifecycle:
            preStop:
              exec:
                command: ["sh", "-c", "echo 'second: preStop hook' > /proc/1/fd/1"]
      containers:
        - name: main
          image: docker.io/library/busybox:1.37.0
          command: ["sh", "-c", "sleep 8"]
```

Apply it:

```sh
kubectl apply -f job-ordered-shutdown.yaml
```

Then check the result. Wait for the Job and print the logs of both sidecars with timestamps:

```sh
kubectl -n starfleet wait --for=condition=Complete job/ordered-shutdown --timeout=120s
kubectl -n starfleet logs job/ordered-shutdown -c second --timestamps
kubectl -n starfleet logs job/ordered-shutdown -c first --timestamps
```

The `second` log shows `started`, then `preStop hook`, then `received SIGTERM`. The `first` log shows `started` and `received SIGTERM`, and its SIGTERM timestamp is later than the one of `second`. Start order was `first`, `second`, `main`. Stop order was `main`, `second`, `first`.

## The grace period

`terminationGracePeriodSeconds` is a field of the Pod spec. It gives the time between the start of termination and the forced kill. The value is one budget for the whole Pod, not one budget per container. If the application containers use all of it, the sidecars get SIGTERM and then SIGKILL almost at once and cannot shut down cleanly. For that reason Kubernetes tools must treat non-zero exit codes of sidecars as normal at Pod termination. The default is 30 seconds. A sidecar that must flush data needs a grace period long enough for the application and the sidecar together.

The shells in these examples use `trap` because a shell running as process 1 of a container ignores signals that it has no handler for. Without the trap, each sidecar would wait for the full grace period.

This part showed why a Job with an ordinary helper container never finishes and how the same helper as a native sidecar lets the Job complete, and it showed that the kubelet stops sidecars after the application and in reverse order. The design rule that follows is simple: put a container in `initContainers` with `restartPolicy: Always` when it must outlive the application and must not block the end of the Pod.

## Common pitfalls

> [!WARNING]
> - The pod template of a Job cannot be edited after creation. To convert a Job, delete it and create a new one.
> - A shipper in `containers` blocks the Job. Moving it to `initContainers` without `restartPolicy: Always` makes it an ordinary init container that must exit before `report` can start, so the Pod waits forever.
> - The grace period is shared. A long `preStop` hook on one sidecar can use the time that other sidecars need.
> - A shell as process 1 ignores SIGTERM unless it has a `trap`. The container then waits for the full grace period and ends with exit code 137.
> - A `preStop` hook that fails or hangs does not stop termination. The kubelet continues after the grace period.
