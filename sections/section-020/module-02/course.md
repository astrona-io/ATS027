---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Finite And Scheduled Application Work

A report generator should exit after writing its output, while the `probe` web server should keep accepting requests. A Job tracks successful completion for the first case. A Deployment maintains continuous replicas for the second.

## Learning Goals

- Distinguish a Job from a long-running service.
- Explain completions, parallelism and retries.
- Compare CronJob overlap policies.
- Evaluate deadlines, idempotence and cleanup.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Jobs, Retries And Scheduled Work
2. Complete A Job And Trigger Scheduled Work Deliberately
3. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
