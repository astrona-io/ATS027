---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Convert A Log Shipper Into A Native Sidecar — Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The steps below were written statically and not run.

Start the lab if it is not running, and select its cluster:

```sh
astrona run -c .
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-030-03-01)"
```

## Step 1: Find the container that blocks the Job

```sh
kubectl -n starfleet get job nightly-report
kubectl -n starfleet get pods -l job-name=nightly-report
```

The Job shows `0/1` completions. The Pod shows `1/2` ready containers: `report` has exited with code 0 and `log-shipper` still runs. A Pod is `Succeeded` only when all its containers have ended, so the Job controller keeps waiting.

## Step 2: Delete the Job

The Pod template of a Job cannot be edited after creation, so the Job must be replaced:

```sh
kubectl -n starfleet delete job nightly-report
astrona submit --keep
```

The checks still fail, because the Job does not exist yet.

## Step 3: Create the Job with a native sidecar

The shipper moves from `containers` to `initContainers` and gets `restartPolicy: Always`. Everything else stays as it was.

Save this as `job-nightly-report.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: nightly-report
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
kubectl apply -f job-nightly-report.yaml
```

Then check the result. The kubelet starts `log-shipper` first, starts `report` after it, and stops the sidecar when `report` has ended:

```sh
kubectl -n starfleet wait --for=condition=Complete job/nightly-report --timeout=120s
kubectl -n starfleet logs job/nightly-report -c log-shipper
```

The Job shows `1/1` completions and the shipper logs contain `shipped: reading 1`, `shipped: reading 2` and `shipped: reading 3`.

```sh
astrona submit --keep
```

## How the pieces fit

The Job controller counts a success when the Pod reaches the phase `Succeeded`. The kubelet decides the phase. With `restartPolicy: Always` on an init container, the kubelet treats the shipper as a helper of the application containers. When `report` exits, the kubelet sends SIGTERM to the sidecar, the `trap` in the shipper script exits with code 0, and the Pod becomes `Succeeded`. The Job controller then marks the Job `Complete`.

When every check passes, remove the lab:

```sh
astrona destroy ats-027-lab-030-03-01
```
