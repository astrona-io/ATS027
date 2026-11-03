# ConfigMap, Secret, Projected And Downward API Volumes - Playground

- **Slug:** ats-027-playground-040-04
- **Status:** UNTESTED. Written statically, never run.

A single-node kind cluster (Kubernetes 1.35). The `scout` Deployment in `starfleet` mounts a ConfigMap and a Secret as volumes, reads one ConfigMap key through an environment variable and one file through `subPath`. The `drifter` Deployment in `outpost` is a plain client.

## Run it

```sh
astrona run -c .
astrona destroy ats-027-playground-040-04
```

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/fixtures.yaml` | Namespaces, ConfigMap, Secret and workloads |
| `docs/overview.md` | What is in the environment and helper functions |
