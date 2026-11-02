---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Run One DaemonSet Pod Per Node Solution

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-020-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-020-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Inspect the relevant evidence:

```sh
kubectl -n starfleet get pods
kubectl -n starfleet get deployment probe -o yaml
```

A DaemonSet controller creates Pods for eligible nodes. A Deployment instead maintains a replica count independently of node count. Check the node names and controller references as well as readiness so manually created Pods cannot stand in for the required controller.


Save this as `daemonset-node-report.yaml`:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-report
  namespace: starfleet
spec:
  selector:
    matchLabels:
      app: node-report
  template:
    metadata:
      labels:
        app: node-report
    spec:
      containers:
      - name: report
        image: docker.io/library/busybox:1.37.0
        command:
        - sh
        - -c
        - sleep 3600
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
```

Apply the required change:

```sh
kubectl apply -f daemonset-node-report.yaml
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet rollout status daemonset/node-report --timeout=180s
```

Create DaemonSet `node-report` with label `app: node-report`, container `report`, BusyBox 1.37.0 and command `sh -c "sleep 3600"`. This lab has one control-plane node and one worker. Add a toleration for the control-plane NoSchedule taint so both nodes are eligible. Keep exactly one ready owned Pod on each eligible node and preserve the ordinary probe Deployment.

After recording the result, remove this independent lab with `astrona destroy ats-027-lab-020-01-01`.

## Common pitfalls

> [!WARNING]
> A replica count does not provide one Pod per node. Keep the control-plane toleration and check DaemonSet owner references. Manually created Pods do not satisfy the controller contract.
