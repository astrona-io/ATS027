---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Ambassador And Adapter Patterns

A legacy application was written to call a fixed address on its own machine, such as `127.0.0.1:9000`, and to write its results in a format that only an old tool understands. Moving it to Kubernetes breaks both assumptions: the service it needs now lives behind a Service name, and the monitoring system expects a different format. Changing the application code is often impossible. Two multi-container Pod patterns solve this without touching the code: the ambassador pattern for outgoing connections and the adapter pattern for outgoing data.

This module builds both patterns with plain busybox and Python containers. You will see why a proxy container in the same Pod can answer on `localhost`, how a ConfigMap changes where the proxy forwards requests, and how a second container reads the output of the first through a shared volume and converts it. You will also learn how these patterns differ from a sidecar that serves the main container for its whole life and from an init container that runs once before startup.

## Learning objectives

After this module you can:

- Explain why containers in one Pod can reach each other on `localhost`, and which Linux feature provides this.
- Build an ambassador container that listens on `localhost` and forwards requests to a Kubernetes Service.
- Supply the ambassador's settings through a ConfigMap volume and explain when a change reaches the container.
- Build an adapter container that reads the output of the main container from a shared `emptyDir` volume and converts it to another format.
- Mount a shared volume read-only in the container that must not change it.
- Tell an ambassador, an adapter, a sidecar and an init container apart by who calls whom and when each container runs.

## Before you start

You need Kubernetes basics: Pods, containers, Services, ConfigMaps, volumes and the commands `kubectl apply`, `kubectl get`, `kubectl logs` and `kubectl exec`. `kubectl` already points at the playground cluster as the cluster administrator.

Your playground is a single-node kind cluster running Kubernetes 1.35:

| Object | What it is |
| --- | --- |
| Namespaces `starfleet` and `outpost` | `starfleet` holds the workloads, `outpost` holds a client Pod |
| Deployment and Service `probe` | A web server that answers every request with `probe-nominal` |
| ConfigMap `ambassador-code` | The Python source of a small HTTP proxy |
| Pod `legacy-scout` | A legacy application that calls `127.0.0.1:9000` and fails |
| Pods `shuttle` and `drifter` | Plain busybox client Pods |

## Reading order

The module has two parts and a summary. The first part, about the ambassador pattern, gives the legacy application a local proxy that forwards to a Service and reads its target from a ConfigMap. The second part, about the adapter pattern, adds a container that translates the output of the main container through a shared volume. The summary closes the module.

Launch your playground now and keep it running while you read the parts:

<!-- astrona:playground -->
