---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Add An Ambassador And An Adapter To A Legacy Application — Task

Solve this question on: `terminal`

The `legacy-scout` in `starfleet` must keep reaching the `probe` Service, but its program only calls `http://127.0.0.1:9000/` and writes its results as `key=value` lines to `/report/report.txt`. The program cannot be changed. Every call fails today and the report contains `status=error`.

The Deployment `legacy-scout` in `starfleet` has one container, `legacy`, and an `emptyDir` volume named `report` mounted at `/report`. The ConfigMap `ambassador-code` holds a proxy program, `proxy.py`. The ConfigMap `uplink-config` holds the proxy destination in the key `upstream.txt`.

1. Add a container named `ambassador` to the Pod template. It uses the image `docker.io/library/python:3.13-alpine`, runs `python /code/proxy.py`, mounts the ConfigMap `ambassador-code` at `/code`, and mounts the ConfigMap `uplink-config` at `/etc/ambassador`.
2. Correct `uplink-config` so that `upstream.txt` holds the address of the `probe` Service in the `starfleet` namespace.
3. Add a container named `adapter` that uses the image `docker.io/library/busybox:1.37.0`, mounts the `report` volume at `/report` read-only, and prints every line of `/report/report.txt` to its standard output as a JSON object, for example `{"status":"ok"}`.
4. The Deployment must end with one available replica, and the `legacy` container must report `status=ok`.

Constraints: do not change the `legacy` container, do not change the `probe` Deployment or Service, and do not copy the Service address into the Pod spec. The destination must come from the ConfigMap. `kubectl` already points at the cluster as the cluster administrator.
