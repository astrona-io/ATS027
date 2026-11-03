---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Summary

A `configMap` or `secret` volume turns every key of the object into one file. The kubelet writes the files into a directory on the node and mounts it into the container. The field `items` selects and renames keys, `mode` sets the permission bits of one file, and `defaultMode` sets them for all files. Write modes in octal with a leading zero. A ConfigMap volume is read-only, and a Secret volume is stored on a `tmpfs`, so its files never reach the node disk.

Files in a volume update after a change, with a delay of up to about a minute, because the kubelet switches a `..data` link to a new directory. Environment variables are fixed when the container starts, and a `subPath` mount bypasses the link, so both keep old values until the Pod restarts. Setting `immutable: true` on a ConfigMap or Secret freezes its data and lowers the kubelet's watch load. A Secret is base64 encoded, not encrypted.

A `projected` volume merges ConfigMap, Secret, downward API and service account token sources into one directory, with a mode for each item. The `serviceAccountToken` source projects a bound token with its own audience and lifetime, and the kubelet refreshes it. The `downwardAPI` source writes Pod fields with `fieldRef` and container limits with `resourceFieldRef`, which needs a `containerName` in a volume. The labels file updates when labels change, and resource limit files stay fixed.

Key facts:

- Volume files update, environment variables and `subPath` mounts do not.
- Secret volumes are `tmpfs`, and default mode is `0644`.
- A projected volume needs distinct paths for all sources.
- Downward API labels use the `key="value"` format, one per line.

<!-- astrona:playground:destroy -->
