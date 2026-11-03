---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Add Ephemeral Volumes To A Deployment - Solution

This walkthrough fixes the lab one step at a time. After each step, run `astrona submit` and read which checks pass.

## Step 1: Look at the starting state

Select the lab cluster and read the Pod spec. The container writes to `/cache` and `/work`, but the Pod has no `volumes`.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-040-03-01)"
kubectl -n starfleet get deploy shuttle -o jsonpath='{.spec.template.spec.volumes}'
```

The command prints nothing, because the Deployment has no volumes. The container creates the directories in its own writable layer.

## Step 2: Add the volumes

Save this as `deployment-shuttle.yaml`. It keeps the original command and adds the memory limit, the two volumes and their mounts:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shuttle
  namespace: starfleet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: shuttle
  template:
    metadata:
      labels:
        app: shuttle
    spec:
      containers:
        - name: app
          image: docker.io/library/busybox:1.37.0
          command:
            - sh
            - -c
            - |
              mkdir -p /cache /work
              [ -f /cache/created ] || echo "$HOSTNAME" > /cache/created
              echo started >> /cache/starts
              [ -f /work/owner ] || echo "$HOSTNAME" > /work/owner
              trap 'exit 1' TERM
              while true; do sleep 1; done
          resources:
            limits:
              memory: 128Mi
          volumeMounts:
            - name: cache
              mountPath: /cache
            - name: work
              mountPath: /work
      volumes:
        - name: cache
          emptyDir:
            medium: Memory
            sizeLimit: 64Mi
        - name: work
          ephemeral:
            volumeClaimTemplate:
              spec:
                accessModes: ["ReadWriteOnce"]
                storageClassName: standard
                resources:
                  requests:
                    storage: 1Gi
```

Apply it:

```sh
kubectl apply -f deployment-shuttle.yaml
```

Then check the result:

```sh
kubectl -n starfleet rollout status deployment/shuttle
kubectl -n starfleet get pvc
astrona submit
```

The Deployment controller starts a new Pod, and the ephemeral-volume controller creates a claim named after that Pod with the suffix `-work`. The checks for the cache volume, the memory limit and the claim now pass.

## Step 3: Prove the restart and replacement behaviour

Stop the container's main process and read the marker file:

```sh
POD="$(kubectl -n starfleet get pod -l app=shuttle -o jsonpath='{.items[0].metadata.name}')"
kubectl -n starfleet exec "$POD" -- kill 1
kubectl -n starfleet exec "$POD" -- cat /cache/starts
```

Wait a few seconds after the kill. The file has two lines, because the kubelet restarted the container in the same Pod and kept the `emptyDir`. Now delete the Pod and read the file in the new Pod:

```sh
kubectl -n starfleet delete pod "$POD"
kubectl -n starfleet rollout status deployment/shuttle
kubectl -n starfleet get pvc
astrona submit
```

The new Pod has a one-line `/cache/starts`, and the claim list shows only the claim of the new Pod. All five checks pass.
