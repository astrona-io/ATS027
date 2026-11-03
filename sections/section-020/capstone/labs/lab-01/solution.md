---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Choose And Use The Right Workload Resource Capstone — Solution

This walkthrough replaces the four workloads in order. After each step, run `astrona submit` to see which checks pass.

## Step 1: select the lab cluster

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-020-capstone)"
kubectl config current-context
```

## Step 2: run the node agent as a DaemonSet

A DaemonSet controller creates one Pod for each eligible node, so it covers new nodes without a replica count. Delete the Deployment first, because it uses the same label:

```sh
kubectl -n starfleet delete deployment node-agent
```

Save this as `daemonset-node-agent.yaml`:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-agent
  namespace: starfleet
spec:
  selector:
    matchLabels:
      app: node-agent
  template:
    metadata:
      labels:
        app: node-agent
    spec:
      containers:
      - name: agent
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "sleep 36000"]
```

Apply it:

```sh
kubectl apply -f daemonset-node-agent.yaml
```

Then check the result:

```sh
kubectl -n starfleet get daemonset node-agent
```

Run `astrona submit`; the first check passes.

## Step 3: run the web tier as a Deployment

A Deployment keeps interchangeable replicas and replaces them with a rolling update. `maxUnavailable: 0` with `maxSurge: 1` starts a new Pod first and removes an old Pod only after the new one is ready, and the readiness probe tells the Deployment controller when a Pod is ready. Delete the bare Pod, because no controller owns it:

```sh
kubectl -n starfleet delete pod scout-web
```

Save this as `deployment-scout-web.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout-web
  namespace: starfleet
spec:
  replicas: 3
  selector:
    matchLabels:
      app: scout-web
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 1
  template:
    metadata:
      labels:
        app: scout-web
    spec:
      containers:
      - name: web
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "mkdir -p /www && echo ok > /www/index.html && httpd -f -p 8080 -h /www"]
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /index.html
            port: 8080
          periodSeconds: 2
```

Apply it:

```sh
kubectl apply -f deployment-scout-web.yaml
```

Then check the result:

```sh
kubectl -n starfleet rollout status deployment/scout-web
```

Run `astrona submit`; the next two checks pass.

## Step 4: run the periodic task as a CronJob

Finite work on a clock is a CronJob. `concurrencyPolicy: Forbid` skips a run while the previous Job is active. Delete the Deployment:

```sh
kubectl -n starfleet delete deployment outpost-sweep
```

Save this as `cronjob-outpost-sweep.yaml`:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: outpost-sweep
  namespace: starfleet
spec:
  schedule: "*/15 * * * *"
  concurrencyPolicy: Forbid
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: sweep
            image: docker.io/library/busybox:1.37.0
            command: ["sh", "-c", "echo sweep done"]
```

Apply it:

```sh
kubectl apply -f cronjob-outpost-sweep.yaml
```

Then check the result by running the template once:

```sh
kubectl -n starfleet create job sweep-now --from=cronjob/outpost-sweep
kubectl -n starfleet wait --for=condition=complete job/sweep-now --timeout=90s
```

Run `astrona submit`; two more checks pass.

## Step 5: run the store as a StatefulSet

A StatefulSet gives each Pod a stable name and its own PersistentVolumeClaim from the volume claim template. It needs a headless Service (`clusterIP: None`) named in `serviceName`, which gives each Pod a stable DNS name. Delete the Deployment:

```sh
kubectl -n starfleet delete deployment ledger
```

Save this as `statefulset-ledger.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ledger
  namespace: starfleet
spec:
  clusterIP: None
  selector:
    app: ledger
  ports:
  - name: tcp
    port: 8080
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: ledger
  namespace: starfleet
spec:
  serviceName: ledger
  replicas: 2
  selector:
    matchLabels:
      app: ledger
  template:
    metadata:
      labels:
        app: ledger
    spec:
      containers:
      - name: ledger
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
kubectl apply -f statefulset-ledger.yaml
```

Then check the result:

```sh
kubectl -n starfleet get pods -l app=ledger
kubectl -n starfleet get pvc
```

The Pods are named `ledger-0` and `ledger-1`, and the claims are named `data-ledger-0` and `data-ledger-1`. Run `astrona submit`. All checks pass.

## Why this works

Each requirement matches one controller contract. The DaemonSet controller ties Pods to nodes. The Deployment controller keeps interchangeable replicas and rolls them out under the limits you set. The CronJob controller creates a finite Job on a schedule. The StatefulSet controller keeps Pod names and claims stable.
