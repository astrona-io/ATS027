---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Add An Ambassador And An Adapter To A Legacy Application — Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The steps below were written statically and not run.

Start the lab if it is not running, and select its cluster:

```sh
astrona run -c .
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-030-02-01)"
```

## Step 1: Read why the application fails

```sh
kubectl -n starfleet logs deploy/legacy-scout -c legacy --tail=3
kubectl -n starfleet get configmap uplink-config -o jsonpath='{.data.upstream\.txt}'
```

The application logs `legacy: uplink failed`, because nothing listens on `127.0.0.1:9000`. The destination in `uplink-config` names the `outpost` namespace, where no `probe` Service exists. Two things are wrong: there is no ambassador, and the destination is wrong.

## Step 2: Correct the destination

Save this as `configmap-uplink.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: uplink-config
  namespace: starfleet
data:
  upstream.txt: "http://probe.starfleet.svc.cluster.local"
```

Apply it:

```sh
kubectl apply -f configmap-uplink.yaml
```

Submit to see which checks pass now:

```sh
astrona submit --keep
```

The destination check still fails, because no Pod mounts the ConfigMap yet.

## Step 3: Add the ambassador and the adapter

A Deployment changes its Pod template through a new revision. Save the full Deployment with the two new containers and the two new volumes. The `legacy` container is copied unchanged.

Save this as `deployment-legacy-scout.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacy-scout
  namespace: starfleet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: legacy-scout
  template:
    metadata:
      labels:
        app: legacy-scout
    spec:
      containers:
        - name: legacy
          image: docker.io/library/busybox:1.37.0
          command: ["sh", "-c"]
          args:
            - |
              while true; do
                echo "time=$(date +%s)" >> /report/report.txt
                if reply="$(wget -q -T 2 -O - http://127.0.0.1:9000/ 2>/dev/null)"; then
                  echo "status=ok" >> /report/report.txt
                  echo "reply=$reply" >> /report/report.txt
                  echo "legacy: uplink ok"
                else
                  echo "status=error" >> /report/report.txt
                  echo "legacy: uplink failed"
                fi
                sleep 5
              done
          volumeMounts:
            - name: report
              mountPath: /report
        - name: ambassador
          image: docker.io/library/python:3.13-alpine
          command: ["python", "/code/proxy.py"]
          volumeMounts:
            - name: code
              mountPath: /code
              readOnly: true
            - name: uplink
              mountPath: /etc/ambassador
              readOnly: true
        - name: adapter
          image: docker.io/library/busybox:1.37.0
          command: ["sh", "-c"]
          args:
            - |
              trap 'exit 0' TERM
              tail -n +1 -F /report/report.txt | while IFS= read -r line; do
                echo "$line" | sed 's/^\([^=]*\)=\(.*\)$/{"\1":"\2"}/'
              done &
              wait $!
          volumeMounts:
            - name: report
              mountPath: /report
              readOnly: true
      volumes:
        - name: report
          emptyDir: {}
        - name: code
          configMap:
            name: ambassador-code
        - name: uplink
          configMap:
            name: uplink-config
```

Apply it:

```sh
kubectl apply -f deployment-legacy-scout.yaml
```

Then check the result. The Deployment controller creates a new ReplicaSet and the old Pod is replaced:

```sh
kubectl -n starfleet rollout status deployment/legacy-scout --timeout=120s
kubectl -n starfleet logs deploy/legacy-scout -c legacy --tail=3
kubectl -n starfleet logs deploy/legacy-scout -c adapter --tail=4
```

The application logs `legacy: uplink ok`. One early `uplink failed` line is possible, because the two containers start together. The adapter prints JSON lines such as `{"status":"ok"}`.

```sh
astrona submit --keep
```

## How the pieces fit

The `ambassador` listens on `127.0.0.1:9000` in the shared network namespace of the Pod, reads `/etc/ambassador/upstream.txt` from the mounted ConfigMap and forwards each request to the `probe` Service. The `adapter` follows `/report/report.txt` through the shared `emptyDir` volume, which it mounts read-only, and rewrites each `key=value` line as a JSON object.

When every check passes, remove the lab:

```sh
astrona destroy ats-027-lab-030-02-01
```
