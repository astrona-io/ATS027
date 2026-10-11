---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Initialization And Supporting Containers

This module connects intended application behavior to declared resources and observed conditions.

## Learning Goals

- Distinguish initialization from continuing assistance.
- Explain native sidecar startup and shutdown.
- Identify shared network and volume relationships.
- Choose a multi-container pattern for a real dependency.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Init Containers And Sidecar Patterns
2. Sharing Pod Resources Without Sharing Every Assumption
3. Observe Initialization And Shared Pod Storage
4. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
