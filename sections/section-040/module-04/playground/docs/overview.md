# Overview: ConfigMap, Secret, Projected And Downward API Volumes (Playground)

This is a playground, not a lab. It starts a fresh cluster and waits. There is no task, no grading and no `astrona submit`. Change the objects, break them, destroy the environment and start again.

## What is in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | ConfigMap `scout-settings` with keys `app.properties` and `log-level`. Secret `scout-credentials` with keys `api-key` and `signing-key`. The `scout` Deployment, with labels `app=scout` and `tier=edge`, a memory limit of `128Mi`, and these mounts: the ConfigMap as a volume at `/etc/scout/settings`, the key `app.properties` again through `subPath` at `/etc/scout/pinned.properties`, the Secret as a volume at `/etc/scout/credentials` with `defaultMode: 0400`, and the environment variable `LOG_LEVEL` from the key `log-level` |
| `outpost` | The `drifter` Deployment, a plain client |

## Helpers

Paste these once in each new terminal. `scout_pod` prints the name of the running `scout` Pod. `scout_read` prints a file inside the `scout` container.

```sh
scout_pod() {
  kubectl -n starfleet get pod -l app=scout -o jsonpath='{.items[0].metadata.name}'
}
scout_read() {
  kubectl -n starfleet exec "$(scout_pod)" -- cat "$1"
}
```

## Practice tasks

- Run `scout_read /etc/scout/settings/app.properties` and `scout_read /etc/scout/pinned.properties`, then change the ConfigMap and compare them after about a minute.
- Run `kubectl -n starfleet exec "$(scout_pod)" -- ls -la /etc/scout/credentials` and read the symbolic links and the modes.
- Read `LOG_LEVEL` with `printenv` before and after you change the ConfigMap key.
- Set `immutable: true` on the ConfigMap and try to change a key.
- Check the file system type of `/etc/scout/credentials` with `df`.
