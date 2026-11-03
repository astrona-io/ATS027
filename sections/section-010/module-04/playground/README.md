# ENTRYPOINT, CMD And Modifying A Deployed Image Playground

UNTESTED: written statically, never run.

A kind cluster where bootstrap builds image `localhost/ckad-probe:v1` on the host (Podman), loads it into the cluster and creates Deployment `probe`, Service `probe`, `shuttle` and `drifter`.

## Run it

```sh
astrona run -c .
astrona destroy ats-027-playground-010-04
```

`astrona destroy` takes the environment name, not the path. There is no grading.
