# Systems profile (Rust / Go / C / C++)
Match: rust, cargo, go, golang, c, c++, cpp, cmake, make, "systems", "daemon",
"embedded", no_std, "performance-critical", "low-level", `.rs`/`.go`/`.c`/`.cpp`.

## Commands
```bash
# Rust
cargo build --release && cargo test && cargo clippy -- -D warnings && cargo fmt
cargo test <name>                 # single test
# Go
go build ./... && go test ./... && go vet ./... && golangci-lint run
go test -run TestName ./pkg/...   # single test
# C/C++ (CMake)
cmake -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build -j && ctest --test-dir build
# Sanitizers (C/C++/unsafe Rust)
cmake -B build -DCMAKE_CXX_FLAGS="-fsanitize=address,undefined" && cmake --build build
```

## Rules
- code-quality.md, testing.md, code-review-graph.md (always)
- error-handling.md (always) — error values/Results, not panics/exceptions in library paths
- Drop frontend.md and database.md unless relevant.

## Domain rules  → .claude/rules/systems.md  (paths: "**/*.rs", "**/*.go", "**/*.c", "**/*.cc", "**/*.cpp", "**/*.h", "**/*.hpp")
- Handle every error path explicitly: Rust → no `.unwrap()`/`.expect()` in library code, return `Result`; Go → check every `err`, wrap with context; C/C++ → check every return code, no leaked resources.
- Concurrency: document ownership/lifetime of shared state; prefer message-passing/channels over shared mutable state; justify every `unsafe`/raw pointer with a comment.
- Run the sanitizers (ASan/UBSan/`cargo miri`, `go test -race`) before claiming memory/concurrency correctness — a clean build proves nothing.
- No allocation or blocking I/O on hot/real-time paths; say so where it matters.
- Treat clippy/vet/`-Wall -Wextra` warnings as errors.

## Permissions
Allow: `Bash(cargo *)`, `Bash(go *)`, `Bash(cmake *)`, `Bash(make *)`,
`Bash(ctest *)`, `Bash(clippy-driver *)`, `Bash(golangci-lint *)`, plus git/gh.

## Gotchas
- The bugs that matter here are memory safety and data races — graph the blast radius and run race/sanitizer tools.
- `cargo fmt`/`gofmt` are non-negotiable; the format-on-save hook handles it.
