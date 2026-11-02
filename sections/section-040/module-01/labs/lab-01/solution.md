---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Preserve Claim Data Across Pod Replacement Solution

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-040-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-040-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Inspect the relevant evidence:

```sh
kubectl -n starfleet get pods
kubectl -n starfleet get deployment probe -o yaml
```

A PersistentVolumeClaim refers to storage independently of the Pod using it. An emptyDir belongs to one Pod. Replacing the Pod leaves the claim data available but creates a new empty scratch volume. The grader verifies the final storage contracts and contents; it cannot prove the earlier scratch write happened.


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
kubectl -n starfleet exec volume-reader -- sh -c 'printf persistent > /data/marker; printf ephemeral > /scratch/marker'
kubectl -n starfleet delete pod volume-reader --wait=true
kubectl apply -f persistentvolumeclaim-probe-data.yaml
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet wait --for=condition=Ready pod/volume-reader --timeout=180s
kubectl -n starfleet exec volume-reader -- sh -c 'cat /data/marker; test ! -e /scratch/marker'
```

Create bound claim `probe-data` requesting 128Mi with ReadWriteOnce access, and Pod `volume-reader` mounting it at `/data` and an emptyDir at `/scratch`. Write `persistent` to `/data/marker` and `ephemeral` to `/scratch/marker`, replace the Pod, then leave the replacement ready with the persistent marker present and no scratch marker. Do not recreate the claim.

After recording the result, remove this independent lab with `astrona destroy ats-027-lab-040-01-01`.

## Common pitfalls

> [!WARNING]
> Replace only the consumer Pod. Recreating the claim can allocate new storage and lose the marker. The scratch volume belongs to one Pod and should be empty in its replacement.
