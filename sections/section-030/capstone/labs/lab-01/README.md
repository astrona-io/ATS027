---
estimated_duration: 40m
---

# Capstone: Multi-Container Pod Design Patterns

**Status: UNTESTED.** Written statically and never run.

Graded capstone for the multi-container Pod section. One Pod combines an init container, a native sidecar ambassador and an adapter around a legacy application. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run -c .
astrona submit
astrona destroy ats-027-lab-030-capstone
```

Authors prove the reference solution with `astrona test -c .`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-init-then-sidecar.sh` | `initContainers` are `fetch-config` (ordinary) then `ambassador` (`restartPolicy: Always`, with a `startupProbe`) |
| `validate-pod-running-ready.sh` | The Deployment is rolled out, the Pod is `Ready` and the sidecar has `started` |
| `validate-upstream-written-by-init.sh` | `/shared/upstream.txt` in the `ambassador` container holds the `probe` Service address |
| `validate-clean-start.sh` | The report has `status=ok` and no `status=error` |
| `validate-adapter-json-readonly.sh` | The `adapter` mounts read-only and prints `{"status":"ok"}` lines |
| `validate-legacy-unchanged.sh` | The `legacy` container still calls `127.0.0.1:9000` |
