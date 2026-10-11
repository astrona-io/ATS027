---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Image Identity And Distribution

This module connects intended application behavior to declared resources and observed conditions.

## Learning Goals

- Explain image layers and immutable digests.
- Distinguish tags from exact image identity.
- Trace image retrieval and registry authentication.
- Diagnose image selection and pull failures.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Layers, Tags And Digests
2. From Build To Image Pull
3. Inspect Image References And Running Content Identity
4. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
