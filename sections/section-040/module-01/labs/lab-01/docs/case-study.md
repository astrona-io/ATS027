---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Starting Environment

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Create bound claim `probe-data` requesting 128Mi with ReadWriteOnce access, and Pod `volume-reader` mounting it at `/data` and an emptyDir at `/scratch`. Write `persistent` to `/data/marker` and `ephemeral` to `/scratch/marker`, replace the Pod, then leave the replacement ready with the persistent marker present and no scratch marker. Do not recreate the claim.
