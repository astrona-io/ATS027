---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Access Modes And Data Retention

Two Pods on the same node may use a ReadWriteOnce volume, even though its name sounds like a single-Pod limit. Access mode describes a storage access constraint, not an application lock. Separate node access from concurrent writers.

## Learning Goals

- Interpret volume access and presentation modes.
- Distinguish node access from application concurrency.
- Predict claim and volume deletion consequences.
- Separate persistent availability from backup and recovery.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Access Modes And Data Presentation
2. Reclaim Policies And Recovery
3. Inspect Access Modes And Change Reclaim Policy Safely
4. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
