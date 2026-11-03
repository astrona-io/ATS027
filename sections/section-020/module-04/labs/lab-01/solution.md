---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Build A StatefulSet With Per-Pod Storage — Solution

Each step ends with `astrona submit`. Add `--keep` to keep the lab running after a failed check. This walkthrough was written without running the lab, so results are described in words.

Select the lab cluster first:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-020-04-01)"
```

## Step 1: Look at the existing Service

```sh
kubectl -n starfleet get service shuttle -o jsonpath='{.spec.clusterIP}{"\n"}'
```

The value is an IP address, so the Service is not headless. The `clusterIP` field of a Service cannot be changed after creation. The Service must be deleted and created again.

```sh
kubectl -n starfleet delete service shuttle
```

## Step 2: Create the headless Service and the StatefulSet

Save this as `statefulset-shuttle.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: shuttle
  namespace: starfleet
spec:
  clusterIP: None
  selector:
    app: shuttle
  ports:
  - name: tcp
    port: 8080
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: shuttle
  namespace: starfleet
spec:
  serviceName: shuttle
  replicas: 3
  persistentVolumeClaimRetentionPolicy:
    whenScaled: Delete
    whenDeleted: Retain
  selector:
    matchLabels:
      app: shuttle
  template:
    metadata:
      labels:
        app: shuttle
    spec:
      containers:
      - name: shuttle
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "sleep 36000"]
        volumeMounts:
        - name: data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 100Mi
```

Apply it:

```sh
kubectl apply -f statefulset-shuttle.yaml
```

Then check the result:

```sh
kubectl -n starfleet rollout status statefulset/shuttle --timeout=240s
kubectl -n starfleet get pods,pvc -l app=shuttle
```

The Pods appear one after another because the default policy is `OrderedReady`. You should see three Pods with ordinal names and the claims `data-shuttle-0` to `data-shuttle-2` in the `Bound` state. Check your progress:

```sh
astrona submit
```

## Step 3: Check DNS and data

Resolve the name of one Pod from inside another Pod:

```sh
kubectl -n starfleet exec shuttle-0 -- nslookup shuttle-1.shuttle.starfleet.svc.cluster.local
kubectl -n starfleet get pod shuttle-1 -o jsonpath='{.status.podIP}{"\n"}'
```

The address in the lookup answer matches the Pod IP. Now prove that data stays:

```sh
kubectl -n starfleet exec shuttle-1 -- sh -c 'echo kept > /data/note'
kubectl -n starfleet delete pod shuttle-1
kubectl -n starfleet wait --for=condition=Ready pod/shuttle-1 --timeout=120s
kubectl -n starfleet exec shuttle-1 -- cat /data/note
astrona submit
```

The file is still there because the new `shuttle-1` attached the claim `data-shuttle-1`. All checks should pass now.
