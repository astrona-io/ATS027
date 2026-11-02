---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Init Containers And Sidecar Patterns

An application needs a prepared file before startup and a log collector throughout execution. The preparation must finish; the collector must remain running. Placing both in one Pod does not make their lifecycle requirements identical.

## Learning objectives

- Distinguish ordinary init containers from continuing sidecars.
- Explain the startup order of init containers and application containers.
- Identify a shared volume needed for file handoff.

## Before you start

Use a shell on your own machine with the module playground running. A Pod is Kubernetes's unit for running one or more containers together. The environment provides the `probe` Deployment, which maintains application Pods, and the `starfleet` namespace, which groups these objects.

Read-only commands below use kubectl, the Kubernetes command-line tool. Select the private kubeconfig: the file that identifies this environment's cluster and credentials. The commands do not change the application.

## Init Containers and Sidecar Patterns

Before `scout` starts, a preparation task must create a file in a shared volume. A regular init container runs before the application containers and must complete successfully. Multiple regular init containers run in their defined order. If initialization cannot finish, the application does not begin normal execution.

A sidecar pattern places a supporting container beside the main application in the same Pod. The helper might forward logs or proxy requests while the application runs. It shares the Pod's lifecycle and network context, which is useful when the two processes need close coordination. An unrelated application with its own scaling needs usually belongs in a separate workload.

Kubernetes also supports restartable init containers for native sidecar behavior. An init container with the supported restart policy can keep running after startup and support ordering relative to other initialization and application containers. This differs from a regular init container, which is expected to finish before normal application startup.

Shared placement does not automatically share files. Both containers need a volume mounted where their processes expect it. They must also avoid conflicting listener ports because the Pod shares a network namespace. Each container has its own image and resource settings.

```mermaid
flowchart TB
    I["Regular init task"] -->|"completes"| A["Application starts"]
    A -->|"runs alongside"| S["Sidecar helper"]
    A -->|"shared mount"| V["Pod volume"]
    S -->|"shared mount"| V
```
A completion task gates startup, while a sidecar supports the running application through explicitly shared resources.

Choose the pattern from duration and coupling. A one-time file preparation step fits a regular init container. Continuous log forwarding fits a sidecar. A separately scalable report processor does not become a sidecar merely because it communicates with the application.

## One-Time Preparation Versus Ongoing Support

Suppose a regular init container writes generated settings to a volume. The main process reads those settings from the same volume. The initializer's image filesystem is separate, so merely writing to an unmounted local directory does not deliver the file. Both containers need mounts that expose the shared data at the expected paths.

Regular init ordering can express dependencies between preparation tasks: download data, transform it, then start the application. Each task must finish successfully. A loop that waits forever for a dependency can block the application indefinitely, so bounded waits and useful failure evidence matter. Initialization cannot guarantee that an external dependency will remain available after startup.

A sidecar provides ongoing support, such as log forwarding or proxying. Its resource consumption contributes to the Pod's needs, and its failures can affect the application even if the main process remains alive. Putting a helper in the same Pod can simplify local communication but couples its placement and replacement to the application.

## Native Sidecar Ordering And Independent Services

A restartable init container uses supported native sidecar behavior rather than regular completion semantics. It can start as part of initialization and continue while application containers run. Startup checks can participate in deciding when subsequent initialization proceeds. This provides an explicit lifecycle contract rather than relying only on two ordinary containers racing to become ready.

A separately scalable backend belongs in its own workload when it serves many application replicas or has independent resource and lifecycle needs. Co-location is not a default for every communicating component. A database used by twenty web replicas should not become twenty uncoordinated helper containers merely to avoid networking.

Choose the container pattern from startup order, duration, shared resources and ownership. A one-time dependency task, an ongoing per-instance helper and an independently operated service are different designs. Their differences determine both startup behavior and the consequences of replacing a Pod.

## Inspect the mechanism

The kubelet runs ordinary init containers in declaration order and waits for each to complete successfully before starting the ordinary application containers. A failed preparation step therefore explains an application that never starts. Its logs and status belong to the init container, not to a nonexistent application process.

A native sidecar is a restartable init container with container-level `restartPolicy: Always`. It can continue supporting the application after its startup requirement is met. An ordinary container used as a traditional sidecar also continues running, but it does not have the same native startup and shutdown contract. Inspect placement and restart policy before inferring which behavior the specification promises.

```mermaid
flowchart TB
    P["Pod creation"] --> I["Ordinary init container"]
    I --> C["Successful completion"]
    C --> A["Application containers"]
    A --> R["Readiness assessment"]
```

Ordinary initialization gates application startup; it is not an additional long-running service.

<!-- astrona:playground:renew -->

Select the private cluster connection and inspect the live state from your host shell:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-playground-030-01)"
if test "$(kubectl config current-context)" = "kind-astro-ats-027-playground-030-01"; then
  kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.initContainers}{"\n"}{.spec.template.spec.containers[*].name}{"\n"}'
  kubectl -n starfleet get pods -l app=probe -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.initContainerStatuses}{"\n"}{end}'
else
  printf "Select this module's private kubeconfig before continuing.\n" >&2
fi
```

The baseline has one application container and no init container. Empty init fields show that starting contract; they do not indicate failed initialization. When initialization is configured, compare desired init container names with their reported completion or waiting states. Readiness and ongoing assistance require separate fields and evidence.

You can now identify which lifecycle a helper needs and where its state is reported. A shared directory still needs explicit mounts, and correct ordering alone does not prove the produced file is usable.

## Common pitfalls

> [!WARNING]
> A regular init container must finish; a sidecar supports ongoing execution. Containers in the same Pod do not automatically share their image filesystems.
