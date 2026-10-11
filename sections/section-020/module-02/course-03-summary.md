---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Summary

Jobs manage successful completion, while CronJobs create Jobs at scheduled times. Parallelism, retries and deadlines constrain different aspects of execution.

Scheduled and retried work must tolerate repeated attempts and imperfect timing. Overlap policies do not provide a universal exact-once guarantee, and cleanup of execution records is separate from retention of application output.

<!-- astrona:playground:destroy -->
