# Ephemeral Volumes - Playground

- **Slug:** ats-027-playground-040-03
- **Status:** UNTESTED. Written statically, never run.

A single-node kind cluster (Kubernetes 1.35). The `scout` Deployment in `starfleet`
mounts a disk `emptyDir`, a memory-backed `emptyDir` with a size limit and a generic
ephemeral volume. The `drifter` Deployment in `outpost` is a plain client.

## Run it

```sh
astrona run -c .
astrona destroy ats-027-playground-040-03
```

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/fixtures.yaml` | Namespaces and workloads |
| `docs/overview.md` | What is in the environment and helper functions |
