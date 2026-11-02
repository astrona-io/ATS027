---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Starting Environment

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Create bound claim `probe-data` requesting 128Mi with ReadWriteOnce access, and Pod `volume-reader` mounting it at `/data` and an emptyDir at `/scratch`. Set the bound PersistentVolume reclaim policy to `Retain` while keeping the claim bound and the Pod ready. Do not delete either object.
