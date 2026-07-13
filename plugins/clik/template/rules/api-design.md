---
paths:
  - "src/api/**"
  - "**/routes/**"
  - "**/controllers/**"
  - "**/interfaces/**"
  - "**/*.proto"
  - "**/graphql/**"
  - "**/schemas/**"
---

# API & Interface Design

- **Contract-first**: design the request/response shape (or function signature) before implementing it. Write it down, get it reviewed, then code to it.
- **Hyrum's Law**: with enough callers, every observable behavior of an interface will be depended on — including bugs and unstated side effects. Treat any behavior change as a breaking change, whether or not it's in the documented contract.
- **One-Version Rule**: don't run two versions of the same interface indefinitely. Ship `v2`, migrate callers, then remove `v1` on a set timeline — don't let both live forever.
- **Error semantics**: consistent error shape across the API, specific error codes (not just 200/400/500), and errors that tell the caller what to do next, not just what went wrong.
- **Boundary validation**: validate and sanitize at the boundary (the API layer), not deep inside business logic. Internal code should be able to trust its inputs once past that boundary.
- Additive changes (new optional field, new endpoint) don't need a version bump. Anything that changes existing behavior for existing callers does.
