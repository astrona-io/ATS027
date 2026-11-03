# Choose And Use The Right Workload Resource Capstone - Lab

Status: UNTESTED (written statically, never run).

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-027-lab-020-capstone
```

| Script | What it checks |
| --- | --- |
| `validate-node-agent.sh` | DaemonSet `node-agent` has one ready Pod per node and no Deployment of that name remains |
| `validate-scout-web-spec.sh` | `scout-web` is a Deployment with 3 ready replicas, a readiness probe, maxUnavailable 0 and a surge; the bare Pod is gone |
| `validate-scout-web-rollout.sh` | A forced rollout finishes and available replicas never drop below 3 |
| `validate-outpost-sweep-spec.sh` | `outpost-sweep` is a CronJob with schedule `*/15 * * * *`, Forbid and one failed Job kept; no Deployment remains |
| `validate-outpost-sweep-runs.sh` | A Job created from the CronJob completes |
| `validate-ledger-spec.sh` | `ledger` is a StatefulSet with 2 ready Pods, a headless Service, claim template `data` and bound claims; no Deployment remains |
| `validate-ledger-identity.sh` | Deleting `ledger-0` brings back a Pod with the same name and the data written to `/data` |
