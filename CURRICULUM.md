# Curriculum Coverage

Exam: Certified Kubernetes Application Developer (CKAD). Domain: Application Design and Build (20%).

The [official objectives](https://training.linuxfoundation.org/certification/certified-kubernetes-application-developer-ckad/) were verified on 2026-10-11. Teaching structure is original; it does not add official exam requirements.

| Section | Official objective | Modules |
| --- | --- | --- |
| 010 | Define, build and modify container images | 2 |
| 020 | Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.) | 2 |
| 030 | Understand multi-container Pod design patterns (e.g. sidecar, init and others) | 1 |
| 040 | Utilize persistent and ephemeral volumes | 2 |

| Section / module | Module | Teaching lessons |
| --- | --- | --- |
| 010 / 01 | Image Identity And Distribution | Layers, Tags And Digests; From Build To Image Pull |
| 010 / 02 | The Image Build And Runtime Contract | Building An Image With A Clear Runtime Contract |
| 020 / 01 | Controllers For Continuous Applications | Managing Long-Running Workloads; Choosing Deployments, DaemonSets And StatefulSets |
| 020 / 02 | Finite And Scheduled Application Work | Jobs, Retries And Scheduled Work |
| 030 / 01 | Initialization And Supporting Containers | Init Containers And Sidecar Patterns; Sharing Pod Resources Without Sharing Every Assumption |
| 040 / 01 | Volume Lifetime And Provisioning | Storage Lifecycles And Claims; Provisioning, Classes And Drivers |
| 040 / 02 | Access Modes And Data Retention | Access Modes And Data Presentation; Reclaim Policies And Recovery |

The module goals and adaptation sources are recorded in AUTHORING.yaml. Every official objective is covered. Each section starts with an introduction, and each module ends with a summary. YAML banks follow the relevant summary and remain separate from the Markdown manifest.

This is a reading-only draft. No new labs, playgrounds, command output or runtime verification are included. ATP006 publication remains draft.

## Hands-On Expansion

Playgrounds and guided practical readings were added on 2026-10-12. Every existing module retains its concept readings and gains one practical reading before its renumbered summary. YAML bank placement follows the new summary path. Official weights, objective IDs and ATP006 links are unchanged. Runtime verification is pending; static checks do not establish successful cluster execution.
