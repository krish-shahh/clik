---
paths:
  - "src/api/**"
  - "src/services/**"
  - "src/middleware/**"
  - "**/routes/**"
  - "**/controllers/**"
  - "**/handlers/**"
  - "**/workers/**"
  - "**/jobs/**"
---

# Observability

## Structured logging

Every log entry at a service boundary (request in, request out, external call, job start/end) must include:

- `requestId` / `traceId` — propagate from the incoming request header (`x-request-id`, `x-trace-id`)
- `userId` — when the operation is user-initiated and a user is known
- `operation` — a stable string name for what is happening (`"payment.create"`, `"user.login"`)
- `durationMs` — for any operation that calls out to a database, cache, or external API
- `status` — `"ok"` or `"error"` (never omit on completion)

Use structured log calls, not string interpolation:

```ts
// correct
logger.info({ requestId, userId, operation: "payment.create", durationMs }, "Payment created")

// wrong — unstructured, unsearchable
console.log(`Payment created for user ${userId} in ${durationMs}ms`)
```

## Log levels

| Level | When |
|-------|------|
| `error` | Unexpected failure that requires human attention |
| `warn` | Recoverable issue, degraded behavior, deprecated usage |
| `info` | Normal operational events (request received, job completed) |
| `debug` | Developer detail — verbose, never on in production |

Never use `console.log` in production code paths. Use the project's logger.

## What never goes in logs

- Passwords, tokens, API keys, session IDs
- Full credit card numbers, SSNs, government IDs
- Raw request bodies on auth endpoints (`/login`, `/register`, `/reset-password`)
- PII beyond what's needed for the operation (name, email — log user ID instead)

Scrub before logging: `{ ...user, password: "[REDACTED]" }`.

## Error tracking

When catching and rethrowing, always preserve the original error as cause:

```ts
// correct
throw new AppError("Payment failed", { cause: originalError, context: { userId, amount } })

// wrong — discards the original stack trace
throw new Error("Payment failed")
```

Include operation context in error reports:
- Which operation failed
- Relevant IDs (user, entity, request)
- What was attempted (not the full request — just the identifying fields)

Never include stack traces in HTTP responses sent to clients.

## Correlation IDs

Generate a `requestId` at the entry point (HTTP middleware, queue consumer, cron trigger) and propagate it through every downstream call. Pass it as a header (`x-request-id`) to outbound HTTP requests. Include it in every log line for the lifetime of the request.

## Metrics naming

If the project emits metrics, use `snake_case` with dot-separated namespaces:

```
http.requests.total
http.request.duration_ms
db.query.duration_ms
jobs.<job_name>.duration_ms
cache.hit_rate
```

Tag with `status` (success/error), `method`, `route` (normalized, not raw URL), `service`.
