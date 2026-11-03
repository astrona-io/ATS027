# Overview: Ambassador And Adapter Patterns (Playground)

This is a playground, not a lab. It starts a fresh cluster with a few workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Create Pods, break them, run `astrona destroy` and start over.

## What is in the box

A single-node kind cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Object | What it is |
| --- | --- |
| Namespace `starfleet` | Holds the workloads below |
| Namespace `outpost` | Holds the `drifter` client Pod |
| Deployment and Service `probe` | A small web server (Python `http.server`) that answers every request with the text `probe-nominal`. The Service listens on port 80 |
| ConfigMap `ambassador-code` | The file `proxy.py`: a small HTTP proxy that listens on `127.0.0.1:9000` and forwards each request to the address in a file (default `/etc/ambassador/upstream.txt`, or the path in the `UPSTREAM_FILE` variable). It answers `/healthz` itself |
| Pod `legacy-scout` | A legacy application (busybox) that calls `http://127.0.0.1:9000/` every five seconds and appends `key=value` lines to `/report/report.txt`. It has no proxy, so every call fails and it writes `status=error` |
| Pods `shuttle` and `drifter` | Plain busybox clients you can use to run `wget` against Services |

## Helpers

Paste these into each new terminal. `report_tail` prints the last lines of the report file of a Pod container. `container_logs` prints the logs of one container in `starfleet`.

```sh
report_tail() {
  kubectl -n starfleet exec "$1" -c "$2" -- tail -n 6 /report/report.txt
}
container_logs() {
  kubectl -n starfleet logs "$1" -c "$2" --tail=10
}
```

Use them like this: `report_tail legacy-scout legacy` and `container_logs legacy-scout legacy`.

## Practice tasks

- Read the logs of `legacy-scout` and explain why every call fails. Name the network address the application uses and which process should listen on it.
- Create a Pod that adds a proxy container to the legacy application and read the report file again.
- Change the address that the proxy forwards to and watch how long the change takes to reach the container.
- Add a second container that only reads the report file, and try to write to the file from it.
