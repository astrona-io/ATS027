---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Summary

Containers of one Pod share a network namespace, so they share the same IP address and the same `localhost`. They do not share a file system, unless both mount the same volume. These two facts make the ambassador and the adapter pattern possible without any change to the application code.

The ambassador receives the outgoing calls of the application on a local port and forwards them to the real destination, such as a Service. The application keeps one fixed address, and the ambassador carries the cluster details. When the ambassador reads its destination from a ConfigMap volume, the destination can change without a new image or a new Pod spec. The kubelet updates the mounted file on a periodic sync, so the change is not instant, and a `subPath` mount never receives it.

The adapter reads the output of the application and converts it to the format of the consumer. It reads through a shared `emptyDir` volume that it mounts read-only, so a fault in the adapter cannot damage the data of the application. The conversion happens after the application writes, and every replica pays for one more container.

The four patterns differ by purpose and by timing. An ambassador represents a remote service for the application. An adapter translates the output. A sidecar is the general helper that runs beside the application for its whole life, and the ambassador and the adapter are two named uses of it. An init container prepares something once and exits before the application starts.

Key facts:

- All containers of a Pod share one network namespace and one IP address.
- A listener on `127.0.0.1` is reachable from every container in the Pod and from nowhere else.
- Two containers in one Pod cannot listen on the same port.
- A ConfigMap volume updates on the kubelet sync period, and not at all with `subPath`.
- A mount with `readOnly: true` makes writes fail with a read-only file system error.

<!-- astrona:playground:destroy -->
