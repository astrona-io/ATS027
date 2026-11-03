---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Ephemeral Volumes: emptyDir And Generic Ephemeral Volumes

A container writes to its own file system layer by default. That layer is thrown away every time the container restarts. An application that needs a scratch directory, a cache, or a place where two containers in one Pod exchange files needs a volume. A volume whose life is tied to the Pod, and not to the cluster, is called an ephemeral volume. Choosing the wrong kind loses data at the wrong moment, or fills the node disk without warning.

This module covers two ephemeral volume types. The `emptyDir` volume is an empty directory that the kubelet creates when a Pod is assigned to a node. The generic ephemeral volume describes a PersistentVolumeClaim inside the Pod, so that a StorageClass can provision real storage for the Pod and remove it again when the Pod goes away.

## Learning objectives

After this module you can:

- Explain when an `emptyDir` is created and deleted, and which events it survives.
- Use `medium: Memory` and `sizeLimit`, and explain how they interact with container memory limits and eviction.
- Explain why a `hostPath` volume is risky and how it differs from an `emptyDir`.
- Declare a generic ephemeral volume with `volumeClaimTemplate` and predict the name and owner of the PersistentVolumeClaim it creates.
- Compare a generic ephemeral volume with a normal PersistentVolumeClaim.

## Before you start

You need Kubernetes basics: Pods, Deployments, containers, `kubectl get`, `kubectl apply`, `kubectl exec` and `kubectl delete`. You need to know what a PersistentVolumeClaim and a StorageClass are.

Your playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | The `scout` Deployment with a disk `emptyDir` at `/scratch`, a memory-backed `emptyDir` at `/cache` and a generic ephemeral volume at `/work` |
| `outpost` | The `drifter` Deployment, a plain client |

`kubectl` already points at the playground cluster. The default StorageClass is `standard`.

## Reading order

Read the two parts in this order: first `emptyDir`, its medium and its size limits, with the `hostPath` and `subPath` comparisons; then generic ephemeral volumes, with the claim that the ephemeral-volume controller creates.

Launch your playground now, and keep it running next to you while you read:

<!-- astrona:playground -->
