# Application Design and Build (ATS027)

Certified Kubernetes Application Developer (CKAD): Application Design and Build, worth 20% of the curriculum and part of ATP006.

Each section has an introduction. Each module combines detailed concept readings, an ungraded isolated playground, guided practical work and a closing summary. YAML knowledge checks remain separately indexed. Technical content stays draft for review. New graded labs are not included.

## Course Outline

| Section / module | Module | Concept and practical readings |
| --- | --- | --- |
| 010 / 01 | Image Identity And Distribution | Layers, Tags And Digests; From Build To Image Pull; Inspect Image References And Running Content Identity |
| 010 / 02 | The Image Build And Runtime Contract | Building An Image With A Clear Runtime Contract; Build And Load A Non-Root Application Image |
| 020 / 01 | Controllers For Continuous Applications | Managing Long-Running Workloads; Choosing Deployments, DaemonSets And StatefulSets; Compare Deployment And DaemonSet Ownership |
| 020 / 02 | Finite And Scheduled Application Work | Jobs, Retries And Scheduled Work; Complete A Job And Trigger Scheduled Work Deliberately |
| 030 / 01 | Initialization And Supporting Containers | Init Containers And Sidecar Patterns; Sharing Pod Resources Without Sharing Every Assumption; Observe Initialization And Shared Pod Storage |
| 040 / 01 | Volume Lifetime And Provisioning | Storage Lifecycles And Claims; Provisioning, Classes And Drivers; Compare Pod-Lifetime And Claim-Lifetime Data |
| 040 / 02 | Access Modes And Data Retention | Access Modes And Data Presentation; Reclaim Policies And Recovery; Inspect Access Modes And Change Reclaim Policy Safely |

## Author Review

See [curriculum coverage](CURRICULUM.md), [primary sources](SOURCES.md), [assessment contracts](ASSESSMENTS.md) and [contribution guidance](CONTRIBUTING.md). Each playground has its own config, bootstrap, guide and author smoke script. Static checks passed; live execution remains pending because the authoring session cannot access the container engine. Retain that limitation until real runtime evidence is recorded.
