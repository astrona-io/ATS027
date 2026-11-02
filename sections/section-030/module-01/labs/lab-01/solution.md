---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Initialize Data Shared By Two Containers Solution

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-030-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-030-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Inspect the relevant evidence:

```sh
kubectl -n starfleet get pods
kubectl -n starfleet get deployment probe -o yaml
```

The kubelet runs ordinary init containers to successful completion before starting application containers. An emptyDir volume belongs to the Pod and can be mounted by each container. Shared files come from the same mounted volume, not from the containers having identical filesystem paths.


Save this as `pod-shared-report.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shared-report
  namespace: starfleet
spec:
  restartPolicy: Never
  containers:
  - name: reader
    image: docker.io/library/busybox:1.37.0
    command:
    - sh
    - -c
    - test "$(cat /shared/message)" = initialized; sleep 3600
    volumeMounts:
    - name: shared
      mountPath: /shared
      readOnly: true
  - name: observer
    image: docker.io/library/busybox:1.37.0
    command:
    - sh
    - -c
    - sleep 3600
    volumeMounts:
    - name: shared
      mountPath: /shared
      readOnly: true
  initContainers:
  - name: prepare
    image: docker.io/library/busybox:1.37.0
    command:
    - sh
    - -c
    - printf initialized > /shared/message
    volumeMounts:
    - name: shared
      mountPath: /shared
  volumes:
  - name: shared
    emptyDir: {}
```

Apply the required change:

```sh
kubectl apply -f pod-shared-report.yaml
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet wait --for=condition=Ready pod/shared-report --timeout=180s
kubectl -n starfleet exec shared-report -c reader -- cat /shared/message
kubectl -n starfleet exec shared-report -c observer -- cat /shared/message
```

Create Pod `shared-report` with init container `prepare` and ordinary containers `reader` and `observer`. The init container writes `initialized` to `/shared/message` on an emptyDir volume named `shared`. Both ordinary containers mount that same volume read-only and remain running. The reader must check the file before sleeping. Both containers must read the initialized value.

After recording the result, remove this independent lab with `astrona destroy ats-027-lab-030-01-01`.

## Common pitfalls

> [!WARNING]
> Both containers must mount the same volume. Equal paths in separate container filesystems do not share data. Ordinary init containers must exit successfully before the application containers start.
