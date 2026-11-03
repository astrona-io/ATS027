---
estimated_duration: 20m
---

# Lab: Recover A Failed Deployment Rollout

UNTESTED: written statically and never run.

Graded lab for the Deployment updates module. The `probe` Deployment in `starfleet` was updated to an image tag that does not exist. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-027-lab-020-03-01
```

Authors prove the reference solution with `astrona test -c .`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-image-restored.sh` | The template uses `docker.io/library/busybox:1.37.0` and no Pod uses the broken tag |
| `validate-rollout-complete.sh` | `kubectl rollout status` succeeds and updated and available replicas equal the desired count |
| `validate-strategy.sh` | `RollingUpdate` with `maxUnavailable` 0 and `maxSurge` 1 |
| `validate-scaled.sh` | `spec.replicas` is 4 and four Pods are ready |
| `validate-same-deployment.sh` | The Deployment UID is unchanged and its revision is 3 or higher |
