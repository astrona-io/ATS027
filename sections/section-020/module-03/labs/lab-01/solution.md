---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Recover A Failed Deployment Rollout — Solution

Each step ends with `astrona submit`. Add `--keep` to keep the lab running after a failed check. This walkthrough was written without running the lab, so descriptions of results say what you should see in words.

Select the lab cluster first:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-020-03-01)"
```

## Step 1: Look at the failed rollout

List the Pods and the revisions of the Deployment:

```sh
kubectl -n starfleet get pods -l app=probe
kubectl -n starfleet rollout history deployment/probe
```

You should see two old Pods that are running and one new Pod that is in `ErrImagePull` or `ImagePullBackOff`. The history shows two revisions. The Deployment controller keeps the old Pods because the new one never becomes available.

## Step 2: Roll back

Return to the previous revision and wait for the rollout:

```sh
kubectl -n starfleet rollout undo deployment/probe
kubectl -n starfleet rollout status deployment/probe --timeout=120s
```

The old ReplicaSet is scaled up and the broken one is scaled to zero. Check your progress:

```sh
astrona submit
```

The checks for the image and the completed rollout should pass now.

## Step 3: Set the strategy

Save this as `patch-probe-strategy.yaml`:

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

Apply it as a patch:

```sh
kubectl -n starfleet patch deployment probe --patch-file patch-probe-strategy.yaml
```

Then check the result:

```sh
kubectl -n starfleet get deployment probe -o jsonpath='{.spec.strategy}{"\n"}'
astrona submit
```

## Step 4: Scale

```sh
kubectl -n starfleet scale deployment/probe --replicas=4
kubectl -n starfleet rollout status deployment/probe --timeout=120s
astrona submit
```

Scaling does not change the Pod template, so it starts no new rollout. All checks should pass.
