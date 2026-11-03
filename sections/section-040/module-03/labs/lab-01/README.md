# Add Ephemeral Volumes To A Deployment - Lab

**Status: UNTESTED.** Written statically, never run.

Graded lab for the ephemeral volumes module. The `shuttle` Deployment in `starfleet` starts with no volumes. The learner adds a memory-backed `emptyDir` and a generic ephemeral volume.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-027-lab-040-03-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-cache-volume.sh` | `cache` is an `emptyDir` with medium `Memory`, `sizeLimit` `64Mi`, mounted at `/cache` |
| `validate-memory-limit.sh` | Container `app` has a memory limit of at least `128Mi` |
| `validate-ephemeral-claim.sh` | Claim `<pod>-work` is Bound, `1Gi`, class `standard`, owned by the Pod |
| `validate-container-restart-keeps-data.sh` | Kills the container process and checks `/cache` data survived in the same Pod |
| `validate-pod-replacement-loses-data.sh` | Deletes the Pod and checks the replacement has an empty `/cache` and a new claim |
