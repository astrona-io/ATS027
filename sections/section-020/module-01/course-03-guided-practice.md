---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Compare Deployment And DaemonSet Ownership

A Deployment manages a requested replica population, while a DaemonSet targets eligible nodes. This playground has a control-plane node and a worker so you can observe placement without assuming all nodes accept the same workloads. You will scale the application and create a separate node-oriented workload.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS027/section-020/module-01/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-playground-020-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-playground-020-01"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Inspect nodes and the current workload, then increase the Deployment replica count.

```sh
kubectl get nodes -o wide
kubectl -n starfleet scale deployment/probe --replicas=3
kubectl -n starfleet rollout status deployment/probe --timeout=120s
kubectl -n starfleet get pods -o wide
```

Replica count is not a request for one Pod on each node. Scheduling follows eligibility and available capacity, including taints and tolerations.

Save a DaemonSet with its own selector. It is a separate controller, so its Pods must not share the Deployment ownership selector.

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
```

Apply or use the saved input, then check the result:

```sh
kubectl apply -f daemonset-node-report.yaml
kubectl -n starfleet rollout status daemonset/node-report --timeout=120s
kubectl -n starfleet get daemonset node-report -o yaml
kubectl -n starfleet get pods -l app=node-report -o wide
```

Compare desiredNumberScheduled with the eligible node set. Do not assume the value equals the total number of nodes without inspecting placement rules.

Restore the application count and remove the separate node workload.

```sh
kubectl -n starfleet scale deployment/probe --replicas=2
kubectl -n starfleet delete daemonset node-report
kubectl -n starfleet rollout status deployment/probe --timeout=120s
```

Each controller reconciles its own desired condition. Removing the DaemonSet does not change the Deployment replica policy.

Use owner references and controller status to explain which component maintains each Pod. A StatefulSet adds ordered identity and storage contracts; it should be selected for those needs rather than as a general replacement for a Deployment. This exercise establishes continuous replica and node-oriented behavior.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
