---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Summary

A Job runs Pods until a target number of them succeed. The Job controller creates the Pods, the scheduler places them and the kubelet runs them. The field `completions` is the target and `parallelism` is the number of Pods allowed to run at once. In Indexed mode the controller numbers the Pods from 0 and passes the number in `JOB_COMPLETION_INDEX`, so each Pod can process its own slice of work.

A Job stops in three ways. It succeeds when the target count is reached. It fails when Pod failures exceed `backoffLimit` or when it runs longer than `activeDeadlineSeconds`. With `restartPolicy: Never` each retry is a new Pod and every failure stays visible. With `OnFailure` the kubelet restarts the container in the same Pod. In Indexed mode, `backoffLimitPerIndex` counts failures for each index. A Job object stays until it is deleted, unless `ttlSecondsAfterFinished` lets the TTL controller remove it.

A CronJob creates Jobs from a template on a schedule. The schedule follows the time zone in `timeZone`. The field `concurrencyPolicy` chooses between `Allow`, `Forbid` and `Replace` when a run is still active at the next time. The field `startingDeadlineSeconds` sets how late a run may start before it counts as missed. The history limits keep the last finished Jobs for debugging. Setting `suspend: true` stops new runs without deleting the CronJob, and `kubectl create job --from=cronjob/<name>` runs the template once on demand.

Key facts:

- Job `restartPolicy` must be `Never` or `OnFailure`.
- `backoffLimit` defaults to 6. History limits default to 3 successful and 1 failed Job.
- Skipped runs under `Forbid` are not made up later.
- Work that a Job runs must be safe to repeat, because a Pod can run twice.

<!-- astrona:playground:destroy -->
