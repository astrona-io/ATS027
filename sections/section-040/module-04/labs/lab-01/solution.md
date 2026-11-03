---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Deliver Configuration Through One Projected Volume - Solution

This walkthrough fixes the lab one step at a time. After each step, run `astrona submit` and read which checks pass.

## Step 1: Read the starting state

Select the lab cluster and read the app log. The app prints `config-missing` until four files exist.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-040-04-01)"
kubectl -n starfleet logs deploy/scout --tail=3
```

The log shows `config-missing`, because the Pod only has the settings file and the app wants a key file and two files about the Pod.

## Step 2: Replace the volume with a projected volume

Save this as `deployment-scout.yaml`. The volume `bundle` merges three sources. Each item has its own `path`, so the files land where the app reads them:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: starfleet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
        tier: edge
    spec:
      containers:
        - name: app
          image: docker.io/library/busybox:1.37.0
          command:
            - sh
            - -c
            - |
              while true; do
                if [ -s /etc/scout/settings/app.properties ] && [ -s /etc/scout/secret/api-key ] && [ -s /etc/scout/meta/labels ] && [ -s /etc/scout/meta/memory-limit ]; then
                  echo "config-complete memory=$(cat /etc/scout/meta/memory-limit)Mi"
                else
                  echo "config-missing"
                fi
                sleep 5
              done
          resources:
            limits:
              memory: 128Mi
          volumeMounts:
            - name: bundle
              mountPath: /etc/scout
              readOnly: true
      volumes:
        - name: bundle
          projected:
            defaultMode: 0440
            sources:
              - configMap:
                  name: scout-settings
                  items:
                    - key: app.properties
                      path: settings/app.properties
                      mode: 0444
              - secret:
                  name: scout-credentials
                  items:
                    - key: api-key
                      path: secret/api-key
                      mode: 0400
              - downwardAPI:
                  items:
                    - path: meta/labels
                      fieldRef:
                        fieldPath: metadata.labels
                    - path: meta/memory-limit
                      resourceFieldRef:
                        containerName: app
                        resource: limits.memory
                        divisor: 1Mi
```

Apply it:

```sh
kubectl apply -f deployment-scout.yaml
```

Then check the result:

```sh
kubectl -n starfleet rollout status deployment/scout
astrona submit
```

The Deployment controller replaces the Pod. The kubelet builds the projected directory from the three sources and mounts it once. The checks for the volume shape, the mount and the downward files pass.

## Step 3: Read the files and the log

Read the modes, the labels file and the app log:

```sh
POD="$(kubectl -n starfleet get pod -l app=scout -o jsonpath='{.items[0].metadata.name}')"
kubectl -n starfleet exec "$POD" -- stat -L -c '%a %n' /etc/scout/settings/app.properties /etc/scout/secret/api-key
kubectl -n starfleet exec "$POD" -- cat /etc/scout/meta/labels /etc/scout/meta/memory-limit
kubectl -n starfleet logs "$POD" --tail=2
astrona submit
```

The modes are `444` and `400`. The labels file lists `app="scout"` and `tier="edge"`, and the memory limit file holds `128`. The log shows `config-complete`, and all five checks pass.
