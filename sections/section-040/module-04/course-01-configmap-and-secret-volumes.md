---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# ConfigMap And Secret Volumes

A container image should not contain a database address, a log level or an API key. These values change between a test cluster and a production cluster, and the image must stay the same. Kubernetes stores them in a ConfigMap, an API object that holds non-secret key-value data, and in a Secret, an API object that holds sensitive key-value data such as passwords and tokens. A Pod can read either object as environment variables or as files in a volume.

This part explains how a volume turns keys into files, how to control which files and which permissions the container sees, and why a file in a volume updates while an environment variable does not.

## Keys become files

When a Pod lists a `configMap` volume, the kubelet (the agent on each node that starts the Pod's containers) reads the ConfigMap from the API server and writes one file for each key into a directory on the node. The file name is the key and the file content is the value. The kubelet then mounts the directory into the container. A `secret` volume works the same way, except that the Secret values are stored base64 encoded in the API and the kubelet decodes them before it writes the files.

The `scout` Deployment in the playground mounts the ConfigMap `scout-settings` at `/etc/scout/settings` and the Secret `scout-credentials` at `/etc/scout/credentials`. Define two helper functions and list the settings directory:

<!-- astrona:playground:renew -->

```sh
scout_pod() {
  kubectl -n starfleet get pod -l app=scout -o jsonpath='{.items[0].metadata.name}'
}
scout_read() {
  kubectl -n starfleet exec "$(scout_pod)" -- cat "$1"
}
kubectl -n starfleet exec "$(scout_pod)" -- ls -la /etc/scout/settings
```

The listing shows the files `app.properties` and `log-level`. Each one is a symbolic link to a file under a directory named `..data`, which is itself a link to a timestamped directory. This layout lets the kubelet replace all files at once, as you will see below.

Without further fields, the volume contains every key. The field `items` selects keys and renames them: each item has a `key`, a `path` for the file name inside the volume, and an optional `mode`. When `items` is present, only the listed keys appear. A listed key that does not exist makes the Pod fail to start, unless the volume has `optional: true`.

## File modes and read-only mounts

The file mode is a set of permission bits written in octal, for example `0644`. The default for both volume types is `0644`, which lets the owner write and everyone read. The field `defaultMode` on the volume sets the mode for all files, and `mode` on one item overrides it. In YAML, write the number with a leading zero, so it is read as octal. A value such as `400` without the zero is read as decimal and gives a different mode.

The Secret `scout-credentials` uses `defaultMode: 0400`, so the owner can read and nobody can write. Check it:

```sh
kubectl -n starfleet exec "$(scout_pod)" -- stat -L -c '%a %n' /etc/scout/credentials/api-key
```

The output is `400 /etc/scout/credentials/api-key`. A ConfigMap volume is always mounted read-only, and the kubelet refuses a write. For a Secret volume, set `readOnly: true` on the `volumeMount` as well, which is what the playground does.

The kubelet stores Secret volumes on a `tmpfs`, a file system that lives in RAM. The files never reach the node disk, and they disappear when the Pod is removed. Run `kubectl -n starfleet exec "$(scout_pod)" -- df /etc/scout/credentials` and read the file system column: it says `tmpfs`. A ConfigMap volume uses the normal Pod directory on the node disk.

## Updates, environment variables and subPath

The kubelet checks the Pod's ConfigMaps and Secrets again on a regular schedule, and it keeps a local cache. When the object changes, the kubelet writes new files into a new timestamped directory and switches the `..data` link to it in one step. The container sees the new content after a delay of up to about a minute. The delay is the sum of the kubelet sync period and the cache time.

Two delivery methods never update. An environment variable gets its value when the container starts, and it keeps that value for the life of the container. A `subPath` mount binds one file from the volume directly, and it bypasses the `..data` link, so the file stays at the old content. The playground has both: `LOG_LEVEL` comes from the key `log-level`, and `/etc/scout/pinned.properties` is a `subPath` mount of `app.properties`.

Save this as `configmap-scout-settings.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: scout-settings
  namespace: starfleet
data:
  app.properties: |
    mode=patrol
    interval=10
  log-level: debug
```

Apply it:

```sh
kubectl apply -f configmap-scout-settings.yaml
```

Then check the result. Wait about a minute, then read the three places:

```sh
scout_read /etc/scout/settings/app.properties
scout_read /etc/scout/pinned.properties
kubectl -n starfleet exec "$(scout_pod)" -- printenv LOG_LEVEL
```

The volume file shows `mode=patrol`. The `subPath` file still shows `mode=survey`, and `LOG_LEVEL` is still `info`. Restarting the Pod, for example with `kubectl -n starfleet rollout restart deploy/scout`, refreshes all three.

## Immutable objects

Set `immutable: true` at the top level of a ConfigMap or Secret to freeze its data. After that the API server rejects every change to `data`, and you can only delete and recreate the object. Immutable objects protect against a bad edit that breaks every Pod at once. They also reduce load, because the kubelet stops watching an immutable object for changes. To roll out a new value, create a new object with a new name and point the Deployment at it.

## What you know now

You know that the kubelet writes one file per key, that `items`, `mode` and `defaultMode` shape the files, and that Secret volumes sit on a `tmpfs`. You know that a volume updates after a short delay, while an environment variable and a `subPath` mount do not. The remaining question is how to put a ConfigMap, a Secret and Pod facts into one directory, which projected volumes do.

## Common pitfalls

> [!WARNING]
> - A Secret is base64 encoded, not encrypted. Anyone who can read the Secret object can decode it.
> - Do not mount a ConfigMap with `subPath` if you need live updates. The file stays at the old content until the Pod restarts.
> - Environment variables from a ConfigMap or Secret never change in a running container. Restart the Pod to read new values.
> - Write modes with a leading zero. `defaultMode: 400` is decimal 400, not octal `0400`.
