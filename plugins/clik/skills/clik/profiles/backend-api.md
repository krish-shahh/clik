# Backend / API profile
Match: api, service, rest, graphql, grpc, fastapi, flask, django, express,
nestjs, spring, rails, gin, axum, "endpoint", "server", "microservice", ORM/DB.

## Commands
```bash
# Run
uvicorn app.main:app --reload     # or: npm run dev / go run ./cmd/server / rails s
# Test
pytest                            # or: npm test / go test ./... / bundle exec rspec
pytest path::test                 # single test
# Lint / types
ruff check . && ruff format .     # or eslint / golangci-lint / rubocop
mypy .                            # or tsc --noEmit
# Migrations (if a DB is present)
alembic upgrade head              # or: prisma migrate dev / rails db:migrate
```

## Rules
- code-quality.md, testing.md, code-review-graph.md (always)
- error-handling.md (always for this profile) — scope paths to handler/service dirs
- security.md (always for this profile) — scope paths to api/auth/middleware dirs
- database.md (if migrations/ORM detected) — scope to the migration dir
- Drop frontend.md.

## Domain rules  → folded into error-handling.md + security.md
- Validate input at the boundary (schemas/DTOs); never trust client data.
- Parameterized queries only — no string-built SQL. ORM or prepared statements.
- Return typed errors with correct status codes; never leak stack traces or internals to clients.
- Authn/authz checked per endpoint; deny by default.
- No secrets in code/logs; read from env/secret store. Log structured events with correlation IDs, never PII or tokens.
- Migrations are forward-only and reversible; never edit a shipped migration.

## Permissions
Allow the detected runtime's run/test/lint/type/migrate commands
(`Bash(uvicorn *)`, `Bash(pytest *)`, `Bash(alembic *)`, `Bash(go run *)`,
`Bash(go test *)`, etc.), plus git/gh from the template. Keep the secret `deny` block.

## Gotchas
- The riskiest changes touch auth, queries, and serialization — get blast radius from the graph first.
- Run migrations in a throwaway/dev DB before claiming they work.
