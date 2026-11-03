# Application Design and Build (ATS027)

Certified Kubernetes Application Developer (CKAD): Application Design and Build, worth 20% of the curriculum and part of ATP006.

Each section has an introduction, modules, a capstone lab and a knowledge check. Each module has detailed readings, an ungraded isolated playground, one or more graded labs and a closing summary. A final domain quiz closes the course. Technical content stays draft for review.

## Course Outline

| Section | Module | Graded lab | Level |
| --- | --- | --- | --- |
| 010 | 01 Image Identity And Distribution | Record A Running Container Image Identity | intermediate |
| 010 | 02 The Image Build And Runtime Contract | Build And Load A Non-Root Image | intermediate |
| 010 | 03 Dockerfile Instructions, Layer Cache And Multi-Stage Builds | Build A Multi-Stage Image And Run It | intermediate |
| 010 | 04 ENTRYPOINT, CMD And Modifying A Deployed Image | Update A Deployment To A Derived Image With Overridden Arguments | intermediate |
| 010 | Capstone | Define, Build And Modify Container Images Capstone | advanced |
| 020 | 01 Controllers For Continuous Applications | Run One DaemonSet Pod Per Node | intermediate |
| 020 | 02 Finite And Scheduled Application Work | Create And Complete A Job | intermediate |
| 020 | 02 Finite And Scheduled Application Work | Trigger A Job From A Suspended CronJob | intermediate |
| 020 | 03 Deployment Updates, Scaling And Rollback | Recover A Failed Deployment Rollout | intermediate |
| 020 | 04 StatefulSets And Stable Identity | Build A StatefulSet With Per-Pod Storage | intermediate |
| 020 | 05 Job Parallelism, Completion Modes And CronJob Policies | Run Indexed Jobs And Set CronJob Policies | intermediate |
| 020 | Capstone | Choose And Use The Right Workload Resource Capstone | advanced |
| 030 | 01 Initialization And Supporting Containers | Initialize Data Shared By Two Containers | intermediate |
| 030 | 02 Ambassador And Adapter Patterns | Add An Ambassador And An Adapter To A Legacy Application | intermediate |
| 030 | 03 Native Sidecar Containers And Pod Lifecycle | Convert A Log Shipper Into A Native Sidecar | intermediate |
| 030 | Capstone | Multi-Container Pod Design Patterns Capstone | advanced |
| 040 | 01 Volume Lifetime And Provisioning | Preserve Claim Data Across Pod Replacement | intermediate |
| 040 | 02 Access Modes And Data Retention | Retain A Bound Volume Safely | intermediate |
| 040 | 03 Ephemeral Volumes: emptyDir And Generic Ephemeral Volumes | Add Ephemeral Volumes To A Deployment | intermediate |
| 040 | 04 ConfigMap, Secret, Projected And Downward API Volumes | Deliver Configuration Through One Projected Volume | intermediate |
| 040 | Capstone | Persistent And Ephemeral Volumes Capstone | advanced |

## Status

Every lab and playground is UNTESTED: it was written and checked statically (`astrona validate -c`, `bash -n`, YAML parsing) and has not been run against a live cluster. Static validation is not runtime evidence.

Author files: [curriculum coverage](CURRICULUM.md), [primary sources](SOURCES.md), [assessment contracts](ASSESSMENTS.md) and [contribution guidance](CONTRIBUTING.md).

