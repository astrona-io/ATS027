# Lab: Define, Build And Modify Container Images Capstone

UNTESTED: written statically, never run. Advanced capstone: multi-stage v1, rollout, derived v2, argument override, Service fix and an image identity record.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-027-lab-010-capstone
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-non-root-no-build-files.sh` | Running container has a non-zero user ID and none of the build-only files |
| `validate-serves-v2.sh` | `shuttle` gets `release=v2` through the `scout` Service |
| `validate-args-override.sh` | `ps` shows `httpd -f -h /www -p 9090` |
| `validate-rolled-out.sh` | Deployment on v2, rolled out, `imagePullPolicy: Never`, two or more ReplicaSets |
| `validate-release-record.sh` | ConfigMap `scout-release` has version v2 and the imageID of every running Pod |
