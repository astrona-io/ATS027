---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Summary

Workload controllers encode desired lifecycle and identity. Deployments manage interchangeable replicas, DaemonSets express node-local presence and StatefulSets preserve member identity and associated storage relationships.

Controller selection does not replace healthy application behavior, storage availability or authorization. Diagnose owner, template, placement and dependencies together when a replacement fails to provide the expected role.

<!-- astrona:playground:destroy -->
