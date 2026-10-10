---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Summary

Build instructions produce a filesystem and startup configuration. The build context controls available inputs, and separate build stages can reduce runtime content without removing necessary dependencies.

Runtime success depends on the executable, arguments, architecture, libraries and effective process identity. A declared port does not create a listener or publish network access, and image changes need clear artifact identity.
