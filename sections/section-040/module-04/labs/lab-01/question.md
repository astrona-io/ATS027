---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Deliver Configuration Through One Projected Volume

The `scout` Deployment in `starfleet` reads its inputs from files under `/etc/scout`. It has only the settings file, from a plain ConfigMap volume, so it logs `config-missing`. Give it all inputs through one projected volume.

Use a host shell with this lab's private kubeconfig:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-040-04-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-040-04-01" || exit 1
```

Every script supplied by the lab refuses a different context.

## Requirements

1. Edit the Deployment `scout`. Do not change its container command, labels or memory limit.
2. Replace the volume `settings` with one `projected` volume named `bundle`, mounted read-only at `/etc/scout` in container `app`. No other ConfigMap or Secret volume may remain.
3. Source 1, ConfigMap `scout-settings`: key `app.properties` at path `settings/app.properties`, mode `0444`.
4. Source 2, Secret `scout-credentials`: key `api-key` at path `secret/api-key`, mode `0400`.
5. Source 3, downward API: the Pod labels at path `meta/labels`, and the memory limit of container `app` in mebibytes at path `meta/memory-limit`.
6. The running app must log `config-complete`.

## Constraints

- Do not copy the Secret value into a ConfigMap or into the Deployment.
- Do not use `subPath`.

Run `astrona submit` when you are ready. Wait until the new Pod is Running before you submit.
