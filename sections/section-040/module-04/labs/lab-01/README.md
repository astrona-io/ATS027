# Deliver Configuration Through One Projected Volume - Lab

**Status: UNTESTED.** Written statically, never run.

Graded lab for the ConfigMap, Secret, projected and downward API module. The `scout` Deployment in `starfleet` starts with only a plain ConfigMap volume. The learner builds one projected volume.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-027-lab-040-04-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-projected-sources.sh` | Volume `bundle` is projected with the ConfigMap, the Secret and two downward API items |
| `validate-no-standalone-volumes.sh` | No separate ConfigMap or Secret volume; `bundle` is read-only at `/etc/scout` |
| `validate-file-modes.sh` | Settings file mode `444`, key file mode `400` inside the container |
| `validate-downward-files.sh` | Labels file contains `tier="edge"`, memory limit file holds `128` |
| `validate-app-reads-config.sh` | The app log shows `config-complete memory=128Mi` |
