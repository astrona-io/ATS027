---
estimated_duration: 20m
---

# Lab: Convert A Log Shipper Into A Native Sidecar

**Status: UNTESTED.** Written statically and never run.

Graded lab for the native sidecar module. The Job `nightly-report` has an ordinary `log-shipper` container that never exits. The learner converts it into a native sidecar. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run -c .
astrona submit
astrona destroy ats-027-lab-030-03-01
```

Authors prove the reference solution with `astrona test -c .`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-job-completes.sh` | The Job reaches `Complete` with one success and no failure |
| `validate-shipper-is-native-sidecar.sh` | `log-shipper` is an init container with `restartPolicy: Always` and is not in `containers` |
| `validate-report-container-unchanged.sh` | `report` is the only application container, still writes the readings, and the Job has no `activeDeadlineSeconds` |
| `validate-shipper-shipped-lines.sh` | The logs of `log-shipper` contain `shipped: reading 1` |
| `validate-pod-succeeded.sh` | The Pod of the Job is in the phase `Succeeded` |
