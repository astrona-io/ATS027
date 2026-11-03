# Deployment Updates, Scaling And Rollback — Playground

UNTESTED: written statically and never run.

An ungraded single-node kind cluster (Kubernetes 1.35). The namespace `starfleet` holds the `probe` Deployment with three replicas; `outpost` is empty.

## Run it

```sh
astrona run -c .
astrona destroy ats-027-playground-020-03
```

`astrona destroy` takes the environment name, not the path. There is no task and no grading.

| Path | Purpose |
| --- | --- |
| `config.yaml` | Runtime, preloaded image and starting manifest |
| `manifests/starfleet.yaml` | Namespaces and the `probe` Deployment |
| `docs/overview.md` | What the environment contains |
