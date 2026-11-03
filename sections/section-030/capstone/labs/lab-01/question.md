---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Multi-Container Pod Design Patterns Capstone — Task

Solve this question on: `terminal`

The `legacy-scout` in `starfleet` must reach the `probe` Service, and the telemetry team needs its report as JSON. The program calls only `http://127.0.0.1:9000/`, writes `key=value` lines to `/report/report.txt`, and must not fail a single call at startup. The Deployment `legacy-scout` has one container, `legacy`, and an `emptyDir` volume named `report` mounted at `/report`. The ConfigMap `ambassador-code` holds a proxy program, `proxy.py`, that forwards requests to the address in the file named by the environment variable `UPSTREAM_FILE`, and that answers `/healthz` itself.

Change the Pod template of the Deployment `legacy-scout` so that one Pod does all of the following:

1. An ordinary init container named `fetch-config` uses `docker.io/library/busybox:1.37.0`. It waits until `http://probe.starfleet.svc.cluster.local/` answers, then writes that address to `/shared/upstream.txt`. It uses an `emptyDir` volume named `shared`.
2. A native sidecar container named `ambassador` is the second init container. It uses `docker.io/library/python:3.13-alpine`, runs `python /code/proxy.py`, mounts the ConfigMap `ambassador-code` at `/code`, sets `UPSTREAM_FILE` to `/shared/upstream.txt`, and mounts `shared` read-only. It has a `startupProbe` that succeeds only when `http://127.0.0.1:9000/healthz` answers, so the application starts after the proxy is ready.
3. An application container named `adapter` uses `docker.io/library/busybox:1.37.0`, mounts `report` at `/report` read-only, and prints each line of `/report/report.txt` as a JSON object such as `{"status":"ok"}`.
4. The `legacy` container keeps its definition, and its report must contain `status=ok` and never `status=error`.

Constraints: do not edit the `legacy` container, do not put the Service address in the `ambassador` container, and do not change the `probe` Deployment or Service. The order of `initContainers` must be `fetch-config` first and `ambassador` second. `kubectl` already points at the cluster as the cluster administrator.
