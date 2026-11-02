---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Starting Environment

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Keep the requested application image `docker.io/library/python:3.13-alpine`. Create ConfigMap `image-report` with keys `requestedImage` and `runtimeImageID`. Record the image reference and the actual nonempty `imageID` reported by a ready probe Pod. A tag is a requested reference; the running identity is reported separately by the runtime.
