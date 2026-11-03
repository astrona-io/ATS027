# Job Parallelism And CronJob Policies - Playground

Status: UNTESTED (written statically, never run).

A single-node kind cluster (Kubernetes 1.35) with the namespaces `starfleet` and `outpost`, a `scout` Deployment in `starfleet` and a CronJob `outpost-sweep` in `outpost`. There is no task and no grading.

```sh
astrona run -c .
astrona destroy ats-027-playground-020-05
```

Files: `config.yaml` (environment), `manifests/fixture.yaml` (starting objects), `docs/overview.md` (guide).
