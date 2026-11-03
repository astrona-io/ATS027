# Persistent And Ephemeral Volumes Capstone - Lab

**Status: UNTESTED.** Written statically, never run.

Capstone for the persistent and ephemeral volumes section. The `probe` Deployment starts with a `ReadWriteMany` 100Mi claim, a claim mounted at the wrong path, the journal written to an `emptyDir`, and a `subPath` settings mount.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-027-lab-040-capstone
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-claim.sh` | `probe-data` is Bound, `ReadWriteOnce`, at least `1Gi`, class `standard` |
| `validate-mount-paths.sh` | The claim is at `/var/lib/probe` and an `emptyDir` is at `/scratch` |
| `validate-config-projected.sh` | `/etc/probe` is a read-only projected volume with `probe.conf` and `labels`, no `subPath` |
| `validate-journal-on-claim.sh` | The journal is on the claim and scratch files are in `/scratch` |
| `validate-replacement-behaviour.sh` | Deletes the Pod; the journal keeps both Pods and scratch is empty of old files |
