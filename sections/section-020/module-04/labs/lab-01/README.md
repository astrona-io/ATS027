---
estimated_duration: 25m
---

# Lab: Build A StatefulSet With Per-Pod Storage

UNTESTED: written statically and never run.

Graded lab for the StatefulSet module. The `starfleet` namespace starts with a normal Service named `shuttle`. The learner builds a headless Service and a StatefulSet with claim templates. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-027-lab-020-04-01
```

Authors prove the reference solution with `astrona test -c .`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-statefulset.sh` | StatefulSet `shuttle` has 3 replicas, `serviceName: shuttle` and Pods `shuttle-0` to `shuttle-2` ready |
| `validate-headless-service.sh` | Service `shuttle` has `clusterIP: None` and the three Pods as endpoints |
| `validate-pod-dns.sh` | `shuttle-1.shuttle.starfleet.svc.cluster.local` resolves to the Pod IP from inside `shuttle-0` |
| `validate-storage-and-data.sh` | Claims `data-shuttle-0` to `-2` are `Bound`; a file survives deletion of `shuttle-1` (the check deletes that Pod) |
| `validate-retention-policy.sh` | `whenScaled` is `Delete` and `whenDeleted` is `Retain` |
