---
draft: true
exam_objectives:
- Define, build and modify container images
---
# The Image Build And Runtime Contract

This module connects intended application behavior to declared resources and observed conditions.

## Learning Goals

- Interpret build context and Dockerfile instructions.
- Distinguish build-time actions from container startup.
- Explain multi-stage runtime dependencies.
- Evaluate command overrides and process permissions.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Building An Image With A Clear Runtime Contract
2. Build And Load A Non-Root Application Image
3. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
