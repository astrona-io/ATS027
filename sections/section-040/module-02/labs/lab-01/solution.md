---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Retain A Bound Volume Safely Solution

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-040-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-040-02-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Inspect the relevant evidence:

```sh
kubectl -n starfleet get pods
kubectl -n starfleet get deployment probe -o yaml
```

ReadWriteOnce describes mounting access, not backup or deletion behavior. The reclaim policy belongs to the PersistentVolume. Retain preserves the volume for deliberate recovery after release; it does not restore an application by itself. Change that field without deleting the bound claim.


Save this as `persistentvolumeclaim-probe-data.yaml`:

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
---
apiVersion: v1
kind: Pod
metadata:
  name: volume-reader
  namespace: starfleet
spec:
  restartPolicy: Never
  containers:
  - name: reader
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

Apply the required change:

```sh
kubectl apply -f persistentvolumeclaim-probe-data.yaml
kubectl -n starfleet wait --for=condition=Ready pod/volume-reader --timeout=180s
bound_volume="$(kubectl -n starfleet get pvc probe-data -o jsonpath='{.spec.volumeName}')"
kubectl patch pv "$bound_volume" --type=merge -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet wait --for=condition=Ready pod/volume-reader --timeout=180s
```

Create bound claim `probe-data` requesting 128Mi with ReadWriteOnce access, and Pod `volume-reader` mounting it at `/data` and an emptyDir at `/scratch`. Set the bound PersistentVolume reclaim policy to `Retain` while keeping the claim bound and the Pod ready. Do not delete either object.

After recording the result, remove this independent lab with `astrona destroy ats-027-lab-040-02-01`.

## Common pitfalls

> [!WARNING]
> Patch the volume bound to this claim, not a similarly named volume. Retain is a reclaim policy, not a backup. Do not delete the active claim to test it.
