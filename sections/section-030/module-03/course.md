---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Native Sidecar Containers And Pod Lifecycle

A helper container such as a log shipper or a proxy must start before the application and stop after it. For years the only tool was an ordinary container, and ordinary containers have no start order and no stop order. A Job that used one never finished, because the helper never exited. Kubernetes now has a native sidecar container: an init container with `restartPolicy: Always`. The kubelet starts it in order, keeps it running, and stops it last.

This module explains what makes a sidecar native, how it changes startup, readiness and resource accounting, how a Pod shuts down in reverse order, and why a Job can finish while its sidecar is still running.

## Learning objectives

After this module you can:

- Write an init container with `restartPolicy: Always` and explain how it differs from an ordinary init container and from an ordinary container.
- Describe the startup order of init containers, sidecars and application containers, and the role of the `startupProbe`.
- Explain how the `readinessProbe` of a sidecar affects the readiness of the Pod.
- Calculate the effective resource request of a Pod that has init containers and sidecars.
- Describe the shutdown order of containers and the role of `terminationGracePeriodSeconds` and `preStop`.
- Convert a Job with a never-ending helper container into a Job with a native sidecar so that the Job completes.

## Before you start

You need Kubernetes basics: Pods, Jobs, volumes, probes and the commands `kubectl apply`, `kubectl get`, `kubectl logs`, `kubectl exec` and `kubectl wait`. `kubectl` already points at the playground cluster as the cluster administrator.

Your playground is a single-node kind cluster running Kubernetes 1.35:

| Object | What it is |
| --- | --- |
| Namespaces `starfleet` and `outpost` | `starfleet` holds the workloads, `outpost` holds a client Pod |
| Deployment and Service `probe` | A web server that answers every request with `probe-nominal` |
| Job `stuck-report` | A Job whose ordinary `log-shipper` container never exits, so the Job never completes |
| Pods `shuttle` and `drifter` | Plain busybox client Pods |

## Reading order

The module has two parts and a summary. The first part, about restartable init containers, shows how the kubelet orders startup, how probes gate it and how resources are counted. The second part, about shutdown order and Jobs, shows reverse-order termination, the grace period, `preStop` hooks, and the Job that finishes despite a running sidecar. The summary closes the module.

Launch your playground now and keep it running while you read the parts:

<!-- astrona:playground -->
