---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Multi-Container Pod Design Patterns Capstone — Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The steps below were written statically and not run.

Start the lab if it is not running, and select its cluster:

```sh
astrona run -c .
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-030-capstone)"
```

## Step 1: Read the problem

```sh
kubectl -n starfleet logs deploy/legacy-scout -c legacy --tail=3
```

The application logs `legacy: uplink failed`. It calls `127.0.0.1:9000`, and no container listens there.

## Step 2: Plan the containers

Four things have to happen in an order. The address of the `probe` Service must be known and the Service must answer, which is one-time preparation, so an ordinary init container does it. The proxy must run for the whole life of the Pod and be ready before the application, so it is a native sidecar after the init container, with a `startupProbe`. The application is the `legacy` container, and the converter that reads its output is an adapter container with a read-only mount.

The `startupProbe` uses `exec` with `wget`, because the kubelet probes the Pod IP address and the proxy listens only on `127.0.0.1`.

## Step 3: Apply the Deployment

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
      terminationGracePeriodSeconds: 10
      initContainers:
        - name: fetch-config
          image: docker.io/library/busybox:1.37.0
          command: ["sh", "-c"]
          args:
            - |
              until wget -q -T 2 -O /dev/null http://probe.starfleet.svc.cluster.local/; do
                echo "waiting for the probe Service"
                sleep 2
              done
              printf '%s' "http://probe.starfleet.svc.cluster.local" > /shared/upstream.txt
              echo "upstream written"
          volumeMounts:
            - name: shared
              mountPath: /shared
        - name: ambassador
          image: docker.io/library/python:3.13-alpine
          restartPolicy: Always
          command: ["python", "/code/proxy.py"]
          env:
            - name: UPSTREAM_FILE
              value: /shared/upstream.txt
          startupProbe:
            exec:
              command: ["wget", "-q", "-T", "2", "-O", "/dev/null", "http://127.0.0.1:9000/healthz"]
            periodSeconds: 2
            failureThreshold: 15
          volumeMounts:
            - name: code
              mountPath: /code
              readOnly: true
            - name: shared
              mountPath: /shared
              readOnly: true
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
        - name: shared
          emptyDir: {}
        - name: code
          configMap:
            name: ambassador-code
```

Apply it:

```sh
kubectl apply -f deployment-legacy-scout.yaml
```

Then check the result. The Deployment controller creates a new ReplicaSet, and the kubelet runs `fetch-config`, then `ambassador`, then `legacy` and `adapter`:

```sh
kubectl -n starfleet rollout status deployment/legacy-scout --timeout=150s
kubectl -n starfleet exec deploy/legacy-scout -c legacy -- cat /report/report.txt
kubectl -n starfleet logs deploy/legacy-scout -c adapter --tail=4
```

The report has `status=ok` lines and no `status=error` line. The adapter prints JSON objects such as `{"status":"ok"}`.

```sh
astrona submit --keep
```

## How the pieces fit

The kubelet runs `fetch-config` until it exits. The container waits for the Service and writes the address to the shared volume. The kubelet then starts `ambassador`, which reads that file, and waits for its `startupProbe` before it starts `legacy` and `adapter`. The legacy program calls `localhost`, the ambassador forwards to the Service, and the adapter reads the report through a read-only mount. At shutdown, the kubelet stops the application containers first and the sidecar last.

When every check passes, remove the lab:

```sh
astrona destroy ats-027-lab-030-capstone
```
