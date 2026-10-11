---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Controllers For Continuous Applications

This module connects intended application behavior to declared resources and observed conditions.

## Learning Goals

- Compare Pod ownership and reconciliation.
- Choose a Deployment for interchangeable replicas.
- Choose a DaemonSet for node-local responsibility.
- Explain StatefulSet identity and storage relationships.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Managing Long-Running Workloads
2. Choosing Deployments, DaemonSets And StatefulSets
3. Compare Deployment And DaemonSet Ownership
4. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
