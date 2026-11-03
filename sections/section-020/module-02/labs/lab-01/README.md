---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Create And Complete A Job

Run finite work with a Job and verify successful completion and its log. This independent graded environment is separate from the module playground.

Author checks: run `astrona validate -c ATS027/sections/section-020/module-02/labs/lab-01` from the workspace. In a fresh lab, run `testing/smoke.sh` with its private kubeconfig to confirm that the initial state fails, the reference solution passes and convergence completes. The grader requires Python 3 on the host.

Runtime verification is pending. Static checks and offline grader tests do not prove cluster execution.

Status: UNTESTED. The lab was written and checked statically only; it has not been run against a live cluster.
