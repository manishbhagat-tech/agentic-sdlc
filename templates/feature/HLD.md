# FEAT-MODULE-000 — HLD

| Field | Value |
|-------|-------|
| **Id** | FEAT-MODULE-000 |
| **Epic** | EPIC-MODULE |
| **Status** | draft |

## API / UI surface

## Data model (delta)

## Authz

## Scalability

- Load / fan-out assumptions
- Caching / async boundaries
- Data growth and retention
- Failure isolation (timeouts, bulkheads)

## Observability

- Metrics (SLIs)
- Structured logs (no secrets/PII dumps)
- Traces / correlation ids
- Alerts for this feature's critical path

## Ledger / anti-patterns

Avoid and document mitigations (see kit `docs/SECURITY-BASELINE.md`):

- [ ] Secrets in repo or client bundles
- [ ] Missing authz / tenant scope on mutations
- [ ] String-built SQL or unsafe shell
- [ ] Silent catch / swallowed errors
- [ ] Unbounded lists / N+1 without pagination
- [ ] Public debug/actuator surfaces

## Test strategy

## Path allowlist hints for stories
