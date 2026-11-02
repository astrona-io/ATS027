---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Volume Lifetime And Provisioning

A report saved inside one container disappears when that container is replaced. A file in `emptyDir` can survive a container restart but not Pod removal. A persistent claim supplies a different storage lifetime, subject to its backend and deletion policy.

## Learning Goals

- Distinguish writable layers, emptyDir and persistent claims.
- Explain volume survival across restart and replacement.
- Trace claim binding and dynamic provisioning.
- Diagnose unavailable storage dependencies.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Storage Lifecycles And Claims
2. Provisioning, Classes And Drivers
3. Compare Pod-Lifetime And Claim-Lifetime Data
4. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
