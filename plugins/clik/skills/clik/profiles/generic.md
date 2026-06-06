# Generic profile
Match: fallback when no domain context is given and detection is inconclusive.

## Commands
Use whatever the detected manifest defines. Common shapes:
- Node: `npm run build` / `npm test` / `npm test -- <file>` / `npm run lint` / `npm run dev`
- Python: `python -m build` / `pytest` / `pytest path::test` / `ruff check .` / `ruff format .`
- Go: `go build ./...` / `go test ./...` / `go vet ./...`
- Rust: `cargo build` / `cargo test` / `cargo clippy` / `cargo fmt`

## Rules
- code-quality.md (always)
- testing.md (always)
- error-handling.md (if there's a backend/service layer)
- security.md (if there's an API/auth surface)
- code-review-graph.md (always)

## Domain rules
None. Keep it lean — don't invent domain rules a generic project won't use.

## Permissions
Allow the detected package manager's build/test/lint/typecheck plus the standard
git + gh entries from the template. Keep the secret `deny` block verbatim.

## Gotchas
- Don't list the file tree in CLAUDE.md — the graph covers structure.
- Prefer fixing root causes over workarounds; run typecheck after a batch of edits.
