---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Build And Load A Non-Root Image

Build a local image, load it into the private cluster and verify its user and response. The task and reference solution use a separate pinned kind cluster. The grader checks declared fields and bounded live evidence. Python 3 is required on the grading host.

Run `testing/smoke.sh` with the lab's private kubeconfig to prove that the starting state fails and the reference repair passes. Each wait and request is bounded. Live verification is pending until actual container-engine execution is recorded. Static checks are not runtime evidence.

Status: UNTESTED. The lab was written and checked statically only; it has not been run against a live cluster.
