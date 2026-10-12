---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Inspect Access Modes And Change Reclaim Policy Safely

Access modes and reclaim policy describe different storage responsibilities. You will provision temporary local storage, inspect its volume and set Retain before observing claim metadata. The exercise does not delete the claim or pretend that Retain is a complete backup strategy.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

The observed access mode describes a supported mounting arrangement. ReadWriteOnce can permit several Pods on one node; it does not serialize their writes. Compare the consumer pattern with the backend's actual capabilities.

Changing reclaim policy affects what follows claim release and is a data lifecycle decision. The exercise inspects and adjusts that policy without deleting the important claim. Retain preserves an opportunity for manual recovery; it neither creates a backup nor automatically makes old data available to a new application.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS027/section-040/module-02/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-playground-040-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-playground-040-02"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Create a claim and consumer to trigger local provisioning. The Pod is part of this module environment, so the operation stands alone.

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
kubectl -n starfleet get pvc probe-data -o yaml
```

ReadWriteOnce describes a node-oriented attachment contract rather than a universal one-Pod lock. Actual behavior depends on the driver and storage system.

Identify the dynamically selected volume and inspect its reclaim policy, storage class and node affinity.

```sh
BOUND_VOLUME=$(kubectl -n starfleet get pvc probe-data -o jsonpath='{.spec.volumeName}')
kubectl get pv "$BOUND_VOLUME" -o yaml
```

Do not substitute an unrelated volume name. The claim supplies the binding relationship, while the PersistentVolume describes the provisioned resource.

Change only that practice volume to Retain and verify the selected field.

```sh
kubectl patch pv "$BOUND_VOLUME" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
kubectl get pv "$BOUND_VOLUME" -o jsonpath='{.spec.persistentVolumeReclaimPolicy}{"\n"}'
kubectl -n starfleet get pod volume-writer
```

Retain changes what happens after the claim releases the volume. It does not replicate data, make node storage survive kind destruction or automate safe reassignment to another tenant.

Access, binding and deletion policy must be assessed independently. Keep this temporary volume inside the isolated playground. Production changes require the actual driver and data-lifecycle contract; this exercise establishes field interpretation without claiming recovery guarantees.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
