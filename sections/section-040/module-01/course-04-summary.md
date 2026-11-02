---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Summary

Container writable layers, Pod-scoped volumes and persistent claims have different lifetimes. A restart inside a Pod and replacement of that Pod can therefore have different effects on stored files.

Persistent storage depends on claim matching, provisioners, access and attachment. A requested volume does not establish availability or a backup, and storage failure must be distinguished from image and application startup failure.

Storage choice begins with the events that data must survive. Claim binding, backend provisioning and node mounting form separate boundaries. Local persistence demonstrates a lifetime relationship, not a universal availability or backup guarantee.

<!-- astrona:playground:destroy -->
