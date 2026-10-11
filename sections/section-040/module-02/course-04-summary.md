---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Summary

Access modes describe supported attachment and use relationships, while volume modes describe how data is presented. Those declarations do not provide application-level coordination for concurrent writers.

Deletion consequences depend on claim ownership, reclaim policy and backend retention. Persistent data still requires a recovery design, and an available volume does not prove that earlier corrupted or deleted data can be recovered.

<!-- astrona:playground:destroy -->
