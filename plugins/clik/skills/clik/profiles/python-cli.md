# Python library / CLI profile
Match: pip package, library, sdk, cli, click, typer, argparse, "tool",
pyproject.toml without a web framework, "publish to PyPI".

## Commands
```bash
# Install editable
pip install -e ".[dev]"           # or: uv pip install -e .
# Test
pytest                            # pytest path::test for one
pytest --cov=<pkg>                # coverage
# Lint / types / format
ruff check . && ruff format .
mypy src/
# Build / publish
python -m build
twine upload dist/*               # only when releasing
# Run the CLI
python -m <pkg> --help            # or the console-script entry point
```

## Rules
- code-quality.md, testing.md, code-review-graph.md (always)
- error-handling.md (CLI surfaces errors to users)
- Drop frontend.md and database.md unless relevant.

## Domain rules  → .claude/rules/python-lib.md  (paths: "src/**/*.py", "**/cli.py", "**/__main__.py")
- Public API is a contract: type-hint everything exported, keep `__all__` honest, don't break signatures without a version bump.
- CLI errors exit non-zero with a clear stderr message — never a raw traceback for user errors.
- Keep side effects out of import time; guard executable code under `if __name__ == "__main__"`.
- Support `--help`/`--version`; validate args before doing work.
- Test the public interface, not internals; add a regression test with every bug fix.

## Permissions
Allow: `Bash(pip install *)`, `Bash(pytest *)`, `Bash(ruff *)`, `Bash(mypy *)`,
`Bash(python -m *)`, `Bash(python -m build)`, plus git/gh. Do NOT auto-allow `twine upload`.

## Gotchas
- Don't commit `dist/`, `*.egg-info/`, or `__pycache__/`.
- Pin a minimum Python version and test against it; f-strings/`match`/typing features leak.
