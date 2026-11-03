# Overview: Job Parallelism And CronJob Policies (Playground)

This is a playground, not a lab. It starts a Kubernetes 1.35 cluster with one node and then waits. Nothing is graded. Create, break and delete objects freely, then run `astrona destroy` to start again.

## What is in the box

| Namespace | Object | What it does |
| --- | --- | --- |
| `starfleet` | Deployment `scout` | One Pod that sleeps. It shows that a Deployment keeps running while a Job ends. |
| `outpost` | CronJob `outpost-sweep` | Runs every ten minutes and prints one line. |

The only image is `busybox:1.37.0`, already loaded on the node. The kubectl context already points at the cluster.

## Helpers

Paste these into each new terminal. `job_pods` lists the Pods of one Job with the completion index label as a column. `job_state` prints the counters the Job controller keeps in the Job status. `job_conditions` prints the condition types and reasons.

```sh
job_pods() {
  kubectl -n "$1" get pods -l job-name="$2" -L batch.kubernetes.io/job-completion-index
}
job_state() {
  kubectl -n "$1" get job "$2" -o jsonpath='active={.status.active} succeeded={.status.succeeded} failed={.status.failed} completedIndexes={.status.completedIndexes}{"\n"}'
}
job_conditions() {
  kubectl -n "$1" get job "$2" -o jsonpath='{range .status.conditions[*]}{.type}={.status} {.reason}{"\n"}{end}'
}
```

Use them like this: `job_pods starfleet probe-scan`, `job_state starfleet probe-scan`, `job_conditions starfleet probe-scan`.

## Ideas to try

- Create a Job with `completions: 4` and `parallelism: 2` and watch how many Pods run at once.
- Make a container exit with status 1 and count the Pods the Job controller creates before the Job fails.
- Suspend the `outpost-sweep` CronJob, then create a Job from it by hand.
