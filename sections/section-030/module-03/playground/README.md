# Native Sidecar Containers And Pod Lifecycle - Playground

- **Slug:** ats-027-playground-030-03
- **Type:** Astrona playground (clean environment, no task, no grading)

**Status: UNTESTED.** These files were written statically and never run.

## Run it

```sh
astrona run -c .
astrona destroy ats-027-playground-030-03
```

`astrona destroy` takes the environment name (`ats-027-playground-030-03`), not the path of the folder.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Runtime, preloaded images and starting manifests |
| `manifests/starfleet.yaml` | Namespaces, the `probe` Deployment and Service, client Pods and the module fixtures |
| `docs/overview.md` | What the environment contains and ideas to try |
