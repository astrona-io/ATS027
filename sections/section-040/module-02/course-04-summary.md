---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Summary

Access modes describe supported attachment and use relationships, while volume modes describe how data is presented. Those declarations do not provide application-level coordination for concurrent writers.

Deletion consequences depend on claim ownership, reclaim policy and backend retention. Persistent data still requires a recovery design, and an available volume does not prove that earlier corrupted or deleted data can be recovered.

Access mode, volume presentation and reclaim policy describe different storage properties. Supported mounting does not ensure safe concurrent writes, and retained backing storage still needs deliberate recovery and application verification.

<!-- astrona:playground:destroy -->
