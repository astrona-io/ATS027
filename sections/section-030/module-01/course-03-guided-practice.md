---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Observe Initialization And Shared Pod Storage

The practice Pod has an init container, a main container and a supporting container. They share an emptyDir volume. Initialization prepares a file before ordinary containers start; the shared volume provides access without implying that every filesystem path or permission is shared.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS027/section-030/module-01/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-playground-030-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-playground-030-01"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Save the complete Pod. Each volumeMount names the declared shared volume, and the init container exits after writing the required file.

Save this as `pod-shared-work.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shared-work
  namespace: starfleet
spec:
  containers:
  - name: main
    image: docker.io/library/busybox:1.37.0
    command:
    - sh
    - -c
    - cat /shared/message; sleep 3600
    volumeMounts:
    - name: shared
      mountPath: /shared
  - name: observer
    image: docker.io/library/busybox:1.37.0
    command:
    - sh
    - -c
    - sleep 3600
    volumeMounts:
    - name: shared
      mountPath: /shared
  initContainers:
  - name: prepare
    image: docker.io/library/busybox:1.37.0
    command:
    - sh
    - -c
    - printf "prepared\n" > /shared/message
    volumeMounts:
    - name: shared
      mountPath: /shared
  volumes:
  - name: shared
    emptyDir: {}
```

Apply or use the saved input, then check the result:

```sh
kubectl apply -f pod-shared-work.yaml
kubectl -n starfleet wait --for=condition=Ready pod/shared-work --timeout=120s
kubectl -n starfleet get pod shared-work -o yaml
```

Read initContainerStatuses separately from ordinary container statuses. Successful preparation is a lifecycle condition, not a permanent background process.

Select containers explicitly when reading logs or executing commands. This avoids guessing which process supplied the evidence.

```sh
kubectl -n starfleet logs shared-work -c main
kubectl -n starfleet exec shared-work -c observer -- cat /shared/message
kubectl -n starfleet logs shared-work -c prepare
```

The observer reads the same volume data. It does not automatically share every process namespace or arbitrary private directory with the main container.

Write a changed value from the observer and read it from the main container.

```sh
kubectl -n starfleet exec shared-work -c observer -- sh -c 'printf "changed\n" > /shared/message'
kubectl -n starfleet exec shared-work -c main -- cat /shared/message
```

This is a shared-volume mutation within one Pod. Deleting that Pod discards its emptyDir; a replacement Pod would execute preparation again.

Use initialization for finite prerequisites and a sidecar for ongoing support. Restartable init sidecars use a different lifecycle contract from this ordinary observer container. State the exact pattern and storage boundary instead of assuming that every multi-container Pod has identical behavior.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
