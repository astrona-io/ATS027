# Lab: Update A Deployment To A Derived Image With Overridden Arguments

UNTESTED: written statically, never run. Start builds image v1 on the host (`bootstrap/image-v1`) and loads it with `podman save` and `kind load image-archive`. The learner builds v2 from v1 and updates Deployment `probe`.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-027-lab-010-04-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-rollout-complete-on-v2.sh` | Image is `localhost/ckad-probe:v2`; all replicas updated and ready |
| `validate-updated-in-place.sh` | Deployment UID equals the one stored in ConfigMap `lab-baseline`; revision is 2 or more |
| `validate-args-override.sh` | `ps` shows `httpd -f -h /www -p 9090` |
| `validate-serves-v2.sh` | `shuttle` gets `image-version=v2` through the Service |
| `validate-pull-policy.sh` | `imagePullPolicy` is `Never` |
