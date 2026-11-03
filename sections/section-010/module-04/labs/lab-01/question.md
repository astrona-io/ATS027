---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Update A Deployment To A Derived Image With Overridden Arguments — Task

The `probe` Deployment in `starfleet` serves `image-version=v1` on port 8080. The team needs version 2 of the image and a different listening port, without deleting the Deployment.

Use a host shell with this lab's private kubeconfig. When the lab starts, it builds `localhost/ckad-probe:v1` with Podman, loads it into the cluster and creates the Deployment `probe` (2 replicas), the Service `probe` on port 80 and the client Pod `shuttle`.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-010-04-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-010-04-01" || exit 1
```

## Requirements

1. Build the image `localhost/ckad-probe:v2` with Podman. Derive it from `localhost/ckad-probe:v1` with `FROM`, so that it serves `image-version=v2` and keeps the entry point and default arguments of version 1.
2. Load the new image into the cluster, named `astro-ats-027-lab-010-04-01`.
3. Update the existing Deployment `probe` to the new image. Keep `imagePullPolicy: Never`.
4. Make the server listen on port 9090 by setting the container `args` to `-p` and `9090`. Do not set `command`.
5. Keep the Service `probe` working: `shuttle` must still get a response from `http://probe.starfleet.svc.cluster.local/`.
6. Wait for the rollout to finish with all replicas ready.

## Constraints

- Update the existing Deployment. Do not delete and recreate it.
- Do not edit the Service `probe`.
- Do not change the namespace, the labels or the replica count.

## Verify the result

`shuttle` must receive `image-version=v2` from the Service. The grader also reads the process list in a `probe` container.
