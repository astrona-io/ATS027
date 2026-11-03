---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# ConfigMap, Secret, Projected And Downward API Volumes

An application needs more than a container image. It needs settings that change between environments, credentials that must not sit in the image, and facts about itself such as its own labels and memory limit. Kubernetes keeps these in separate objects and hands them to the Pod as files, so the same image runs everywhere with different inputs. A file mounted from an object can also change while the Pod runs, and some mount styles stop that update without any warning.

This module covers the four volume types that deliver cluster data as files: the `configMap` volume, the `secret` volume, the `projected` volume that merges several sources into one directory, and the `downwardAPI` volume that exposes Pod fields.

## Learning objectives

After this module you can:

- Mount a ConfigMap or Secret as a volume and explain how each key becomes a file.
- Select keys with `items` and set file permissions with `mode` and `defaultMode`.
- Predict which delivery methods receive updates: volume files do, and environment variables and `subPath` mounts do not.
- Explain `immutable` and why a Secret volume is held in memory.
- Merge a ConfigMap, a Secret, a service account token and Pod information into one `projected` volume.
- Expose Pod labels and container resource limits as files with the downward API.

## Before you start

You need Kubernetes basics: Pods, Deployments, labels, `kubectl get`, `kubectl apply`, `kubectl exec` and `kubectl describe`. You need to know that a ConfigMap stores non-secret settings and a Secret stores sensitive values.

Your playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | ConfigMap `scout-settings`, Secret `scout-credentials` and the `scout` Deployment that mounts both as volumes, with one `subPath` mount and one environment variable for comparison |
| `outpost` | The `drifter` Deployment, a plain client |

`kubectl` already points at the playground cluster.

## Reading order

Read the two parts in this order: first ConfigMap and Secret volumes, with file modes, live updates and immutability; then projected and downward API volumes, with token projection and files that describe the Pod.

Launch your playground now, and keep it running next to you while you read:

<!-- astrona:playground -->
