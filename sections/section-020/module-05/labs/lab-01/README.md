# Run Indexed Jobs And Set CronJob Policies - Lab

Status: UNTESTED (written statically, never run).

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-027-lab-020-05-01
```

| Script | What it checks |
| --- | --- |
| `validate-indexed-job-spec.sh` | `probe-scan` is Indexed with completions 3, parallelism 2, backoffLimit 2, TTL 600, restartPolicy Never |
| `validate-indexed-job-completed.sh` | The Job is Complete, completed indexes are `0-2`, each Pod logged its slice |
| `validate-cronjob-policies.sh` | `shuttle-report` has Forbid, history 2 and 1, Europe/Copenhagen, deadline 120, schedule unchanged |
| `validate-cronjob-runs.sh` | A Job created from the CronJob completes, and the CronJob is not suspended |
