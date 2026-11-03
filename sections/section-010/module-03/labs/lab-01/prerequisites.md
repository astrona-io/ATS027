---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Prerequisites

Use a host shell with `astrona`, `kubectl`, Podman and `kind`. Podman builds the image on your machine. The `kind` command loads the image into the lab cluster. You need no registry account, because the image never leaves your machine.

A kubeconfig is the file that identifies the cluster and the credentials that `kubectl` uses. Select the private kubeconfig of this lab:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-010-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-010-03-01" || exit 1
```

Keep this connection selected during the task. Every script of the lab refuses a different context.
