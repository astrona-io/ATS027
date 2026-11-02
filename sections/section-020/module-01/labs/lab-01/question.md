---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Run One DaemonSet Pod Per Node

Choose DaemonSet ownership for a workload that must cover each eligible node. Use the isolated `starfleet` environment to verify the result.

## Objective

Choose DaemonSet ownership for a workload that must cover each eligible node.

## Starting state

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-020-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-020-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Create DaemonSet `node-report` with label `app: node-report`, container `report`, BusyBox 1.37.0 and command `sh -c "sleep 3600"`. This lab has one control-plane node and one worker. Add a toleration for the control-plane NoSchedule taint so both nodes are eligible. Keep exactly one ready owned Pod on each eligible node and preserve the ordinary probe Deployment.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.
