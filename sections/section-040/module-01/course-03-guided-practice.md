---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Compare Pod-Lifetime And Claim-Lifetime Data

An emptyDir follows a Pod lifetime, while a PersistentVolumeClaim can outlive that Pod. The kind practice cluster supplies local-path provisioning for temporary local storage. You will write distinct markers, replace the consumer Pod and inspect what remains under each storage contract.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS027/section-040/module-01/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-playground-040-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-playground-040-01"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Save the claim and consumer Pod together as separate declarations. Wait for the consumer, because a delayed-binding provisioner can require scheduling before it provisions storage.

Save this as `pvc-probe-data.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: probe-data
  namespace: starfleet
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 128Mi
```

Save this as `pod-volume-writer.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-writer
  namespace: starfleet
spec:
  containers:
  - name: writer
    image: docker.io/library/busybox:1.37.0
    command:
    - sh
    - -c
    - sleep 3600
    volumeMounts:
    - name: data
      mountPath: /data
    - name: scratch
      mountPath: /scratch
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: probe-data
  - name: scratch
    emptyDir: {}
```

Apply or use the saved input, then check the result:

```sh
kubectl apply -f pvc-probe-data.yaml
kubectl apply -f pod-volume-writer.yaml
kubectl -n starfleet wait --for=condition=Ready pod/volume-writer --timeout=120s
kubectl -n starfleet get pvc probe-data
```

Inspect the bound volume and storage class. Local-path storage is an environment dependency rather than portable replicated production storage.

Write one marker to the claim mount and another to the emptyDir mount.

```sh
kubectl -n starfleet exec volume-writer -- sh -c 'printf persistent > /data/marker; printf ephemeral > /scratch/marker'
kubectl -n starfleet exec volume-writer -- cat /data/marker /scratch/marker
```

The two paths reside under different lifetime contracts even though one process can read both. A container restart is not the same experiment as replacing the whole Pod.

Delete and recreate only the consumer Pod, leaving the claim intact.

```sh
kubectl -n starfleet delete pod volume-writer
kubectl apply -f pod-volume-writer.yaml
kubectl -n starfleet wait --for=condition=Ready pod/volume-writer --timeout=120s
kubectl -n starfleet exec volume-writer -- sh -c 'cat /data/marker; test ! -e /scratch/marker'
```

The persistent marker should remain while the emptyDir marker should be absent. If scheduling cannot reuse the volume, inspect node affinity and binding evidence instead of assuming the claim copied data.

Persistence is scoped to the provisioned volume and environment. Destroying this playground removes its kind node storage. The result demonstrates consumer replacement, not durability across cluster destruction, disk failure or a production recovery event.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
