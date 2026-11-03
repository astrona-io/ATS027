---
estimated_duration: 25m
---

# Lab: Add An Ambassador And An Adapter To A Legacy Application

**Status: UNTESTED.** Written statically and never run.

Graded lab for the ambassador and adapter module. The Deployment `legacy-scout` calls `127.0.0.1:9000` and writes a `key=value` report. The learner adds an ambassador and an adapter. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run -c .
astrona submit
astrona destroy ats-027-lab-030-02-01
```

Authors prove the reference solution with `astrona test -c .`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-ambassador-answers.sh` | `wget` from the `legacy` container to `127.0.0.1:9000` returns `probe-nominal` |
| `validate-report-status-ok.sh` | The report of the `legacy` container contains `status=ok` |
| `validate-upstream-from-configmap.sh` | `uplink-config` names the `probe` Service in `starfleet`, is mounted in the Pod and an `ambassador` container exists |
| `validate-adapter-json.sh` | The logs of the `adapter` container contain `{"status":"ok"}` |
| `validate-adapter-readonly-legacy-unchanged.sh` | Every volume mount of `adapter` is read-only and the `legacy` container still calls `127.0.0.1:9000` |
