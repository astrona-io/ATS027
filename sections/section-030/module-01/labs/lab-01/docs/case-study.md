---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Starting Environment

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Create Pod `shared-report` with init container `prepare` and ordinary containers `reader` and `observer`. The init container writes `initialized` to `/shared/message` on an emptyDir volume named `shared`. Both ordinary containers mount that same volume read-only and remain running. The reader must check the file before sleeping. Both containers must read the initialized value.
