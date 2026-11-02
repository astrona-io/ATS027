---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Trigger A Job From A Suspended CronJob

Declare a schedule and deliberately run its template once without waiting for the clock. Use the isolated `starfleet` environment to verify the result.

## Objective

Declare a schedule and deliberately run its template once without waiting for the clock.

## Starting state

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-020-02-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-020-02-02" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Create suspended CronJob `scheduled-report` with schedule `*/5 * * * *`, `concurrencyPolicy: Forbid` and the shown finite report command. Keep it suspended so the exercise creates no automatic work. Trigger Job `scheduled-once` from its template. That Job must complete and log `scheduled-report`.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.
