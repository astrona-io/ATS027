---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Starting Environment

The `starfleet` namespace exists and no Job named `report` has been created. A Job is a controller that runs a finite task until its required number of successful completions is reached.

Create Job `report` in `starfleet`. Use container `report` with image `docker.io/library/busybox:1.37.0`, command `["sh", "-c", "printf 'report-complete\n'"]`, Pod restart policy `Never`, one completion, parallelism one and `backoffLimit: 2`. Keep the completed Job for grading. It must report a successful Complete condition and its Pod log must contain a line `report-complete`.
