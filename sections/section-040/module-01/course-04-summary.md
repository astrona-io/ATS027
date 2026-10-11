---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Summary

Container writable layers, Pod-scoped volumes and persistent claims have different lifetimes. A restart inside a Pod and replacement of that Pod can therefore have different effects on stored files.

Persistent storage depends on claim matching, provisioners, access and attachment. A requested volume does not establish availability or a backup, and storage failure must be distinguished from image and application startup failure.

<!-- astrona:playground:destroy -->
