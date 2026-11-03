---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Persistent And Ephemeral Volumes Capstone - Solution

This walkthrough finds each fault in turn. After each step, run `astrona submit` and read which checks pass.

## Step 1: Find why the Pod does not start

Select the lab cluster and look at the claim and the Pod:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-040-capstone)"
kubectl -n starfleet get pvc,pod
kubectl -n starfleet describe pvc probe-data
```

The claim asks for `ReadWriteMany` and only `100Mi`. The `standard` provisioner in kind supports only single-node access, so the claim does not bind and the Pod waits. The events of the claim show the provisioning problem. The fields `accessModes` and `resources.requests.storage` of a bound or pending claim cannot be edited to fix this, so the claim has to be recreated.

## Step 2: Recreate the claim

A claim that a Pod uses is protected from deletion. Delete the Deployment first, then the claim:

```sh
kubectl -n starfleet delete deployment probe
kubectl -n starfleet delete pvc probe-data
```

The Deployment is created again in the next step. The ConfigMap `probe-settings` stays.

## Step 3: Apply the fixed claim and Deployment

The app writes its journal to `JOURNAL_DIR`, which is `/var/lib/probe`, and its scratch files to `SCRATCH_DIR`, which is `/scratch`. The starting state mounted an `emptyDir` at `/var/lib/probe` and the claim at `/data`. The fix swaps them and adds the projected configuration volume. Save this as `probe.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: probe-data
  namespace: starfleet
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: standard
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: probe
  template:
    metadata:
      labels:
        app: probe
    spec:
      containers:
        - name: app
          image: docker.io/library/busybox:1.37.0
          env:
            - name: JOURNAL_DIR
              value: /var/lib/probe
            - name: SCRATCH_DIR
              value: /scratch
          command:
            - sh
            - -c
            - |
              mkdir -p "$JOURNAL_DIR" "$SCRATCH_DIR"
              echo "$HOSTNAME" >> "$JOURNAL_DIR/journal"
              echo working > "$SCRATCH_DIR/work-$HOSTNAME"
              trap 'exit 1' TERM
              while true; do sleep 1; done
          resources:
            limits:
              memory: 64Mi
          volumeMounts:
            - name: data
              mountPath: /var/lib/probe
            - name: scratch
              mountPath: /scratch
            - name: config
              mountPath: /etc/probe
              readOnly: true
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: probe-data
        - name: scratch
          emptyDir:
            sizeLimit: 128Mi
        - name: config
          projected:
            sources:
              - configMap:
                  name: probe-settings
                  items:
                    - key: probe.conf
                      path: probe.conf
              - downwardAPI:
                  items:
                    - path: labels
                      fieldRef:
                        fieldPath: metadata.labels
```

Apply it:

```sh
kubectl apply -f probe.yaml
```

Then check the result:

```sh
kubectl -n starfleet rollout status deployment/probe
kubectl -n starfleet get pvc probe-data
astrona submit
```

The `kind` provisioner creates the volume when the scheduler places the Pod, and the claim becomes `Bound`. The claim, mount path, projected configuration and journal checks pass.

## Step 4: Prove replacement behaviour

Read the journal, replace the Pod and read it again:

```sh
POD="$(kubectl -n starfleet get pod -l app=probe -o jsonpath='{.items[0].metadata.name}')"
kubectl -n starfleet exec "$POD" -- cat /var/lib/probe/journal
kubectl -n starfleet delete pod "$POD"
kubectl -n starfleet rollout status deployment/probe
kubectl -n starfleet exec deploy/probe -- sh -c 'cat /var/lib/probe/journal; ls /scratch'
astrona submit
```

The journal now lists the old and the new Pod names, because it sits on the claim. The `ls` output shows only the scratch file of the new Pod, because the `emptyDir` was removed with the old Pod. All five checks pass.
