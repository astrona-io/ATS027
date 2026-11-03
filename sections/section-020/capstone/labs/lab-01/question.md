---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Choose And Use The Right Workload Resource Capstone — Task

The crew of the `starfleet` namespace deployed four workloads with the wrong workload kind, and each one misbehaves. Replace each workload with the kind that matches its requirement.

Use the kubectl context of this lab:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-020-capstone)"
kubectl config current-context
```

The context must be `kind-astro-ats-027-lab-020-capstone`. All objects are in the namespace `starfleet`. Every container uses the image `docker.io/library/busybox:1.37.0`.

## Requirements

1. `node-agent` must run one Pod on every node and follow the nodes as they come and go. It is a Deployment with two replicas now. Keep the label `app: node-agent` and the command `sh -c "sleep 36000"`.
2. `scout-web` is a stateless web tier. It is a bare Pod now. It must run three interchangeable replicas, replace failed Pods by itself, and update without ever dropping below three available replicas. Keep the label `app: scout-web`, the container name `web` and the Pod command and port 8080 from the current Pod. Add a readiness probe that sends an HTTP request to `/index.html` on port 8080.
3. `outpost-sweep` is a periodic batch task that runs every 15 minutes, finishes, and must never run twice at the same time. It is a Deployment with a loop now. Run the command `sh -c "echo sweep done"`. Keep one failed Job in the history.
4. `ledger` is a store with two members. Each member needs a stable Pod name (`ledger-0`, `ledger-1`) and its own storage that survives a Pod being deleted. It is a Deployment with an `emptyDir` volume now. Name the Service and the controller `ledger`, name the volume claim template `data`, and mount it at `/data`. Keep the label `app: ledger` and the command `sh -c "sleep 36000"`.
5. When you finish, no Deployment named `node-agent`, `outpost-sweep` or `ledger` and no bare Pod named `scout-web` may remain.

## Constraints

- Do not change the namespace or the images.
- Choose the workload kind from the requirement. Do not keep a wrong kind and add scripts or extra Pods to imitate the right one.
