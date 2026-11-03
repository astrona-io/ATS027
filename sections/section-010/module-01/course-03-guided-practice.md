---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Inspect Image References And Running Content Identity

The running probe uses a tagged Python image. You will compare the declared reference, the image identity reported by a running container and the host image metadata. These observations describe different boundaries: a tag is a selection name, while a digest identifies content under the registry and runtime contract.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

The declared tag and runtime image identity answer different questions. The first selects content; the second reports what the runtime actually used. Compare both with the host image metadata without assuming that a host cache is the same store as every kind node.

A restart creates another startup under the admitted pull policy. It does not necessarily retrieve newly moved tag content under `IfNotPresent`. Mounted configuration can also change behavior without changing the image, so keep artifact and runtime inputs separate.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS027/section-010/module-01/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-playground-010-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-playground-010-01"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Read the desired image and pull policy, then inspect the identity of images actually used by the Pods. The workload must be running before container status can report realized identity.

```sh
kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}{.spec.template.spec.containers[0].imagePullPolicy}{"\n"}'
kubectl -n starfleet get pods -l app=probe -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.containerStatuses[0].imageID}{"\n"}{end}'
```

Do not invent a universal digest value. Platform architecture and current tag resolution influence the realized content. Compare identities rather than copying a digest from an unrelated image.

Inspect the host copy used during playground image preloading. This is a container-engine observation rather than Kubernetes API data.

```sh
podman image inspect docker.io/library/python:3.13-alpine
podman image inspect docker.io/library/busybox:1.37.0
```

The host store and each kind node store are separate. Having an image on the host does not by itself prove every node can run a newly built image.

Restart the workload and inspect its new Pods under the same declared image policy.

```sh
kubectl -n starfleet rollout restart deployment/probe
kubectl -n starfleet rollout status deployment/probe --timeout=120s
kubectl -n starfleet describe pods -l app=probe
```

This provides another observed start. If the tag remains cached under IfNotPresent, restarting is not a guarantee that a registry tag was resolved afresh.

An immutable content reference can improve repeatability, while a tag remains useful selection metadata. Image identity does not prove the application is safe or configured correctly. Preserve the difference between desired reference, downloaded content and runtime health.

## What each observation proves

Each command above reads from a different component, so each result proves a different fact. The Deployment spec is stored in the API server and records only what the user asked for: an image reference and a pull policy. The `imageID` field in the Pod status comes from the kubelet, which copies it from the container runtime after the runtime pulled and started the image. The host `podman image inspect` command reads the local image store of the host, which is not a node of the cluster.

Read the three results in that order. If the spec holds only a tag, the tag tells you what the user selected but not which content ran. If the `imageID` holds a `sha256` digest, it tells you the content that this one container started from. If two Pods of the same Deployment report different digests, the nodes pulled the tag at different times and the tag moved between the pulls.

This reading also shows what an image identity does not prove. A matching digest says the bytes of the image are the same. It does not say that the configuration, the mounted volumes or the environment variables are the same, and those inputs change what the process does at run time. Compare the artifact and the runtime inputs separately when two Pods behave differently from the same image.


## Pull policy decides whether the registry is asked

The kubelet reads `imagePullPolicy` from the container spec each time it starts a container. With `Always`, it asks the registry to resolve the tag to a digest on every start and downloads only the layers it does not already hold. With `IfNotPresent`, it uses an image stored on the node when one exists under that name, and asks the registry only when none exists. With `Never`, it never contacts a registry and fails with `ErrImageNeverPull` when the image is missing.

When the field is not set, the API server fills in a default at admission time: `Always` when the tag is `latest` or there is no tag, and `IfNotPresent` for every other tag. Read the value with the first jsonpath command above rather than assuming it, because the defaulted value is stored in the spec.

A reference of the form `name@sha256:<digest>` removes the movable part. The runtime resolves it to exactly one manifest, so every node that starts the container runs the same image content, whatever the pull policy is. This is the strongest way to make two starts comparable, and it is the form that the `imageID` field reports.

After you compare the results, state the conclusion in one sentence for each source: what the spec requested, what the runtime started, and what the host stores.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
