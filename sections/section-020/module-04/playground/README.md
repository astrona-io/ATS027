# StatefulSets And Stable Identity — Playground

UNTESTED: written statically and never run.

An ungraded single-node kind cluster (Kubernetes 1.35). `starfleet` is empty. `outpost` holds the `drifter` Deployment, a `busybox` Pod for DNS lookups. The default StorageClass `standard` provisions volumes for StatefulSet claims.

## Run it

```sh
astrona run -c .
astrona destroy ats-027-playground-020-04
```

`astrona destroy` takes the environment name, not the path. There is no task and no grading.

| Path | Purpose |
| --- | --- |
| `config.yaml` | Runtime, preloaded image and starting manifest |
| `manifests/environment.yaml` | Namespaces and the `drifter` Deployment |
| `docs/overview.md` | What the environment contains |
