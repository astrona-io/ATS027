---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Starting Environment

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Create suspended CronJob `scheduled-report` with schedule `*/5 * * * *`, `concurrencyPolicy: Forbid` and the shown finite report command. Keep it suspended so the exercise creates no automatic work. Trigger Job `scheduled-once` from its template. That Job must complete and log `scheduled-report`.
