# Data visualization profile
Match: data viz, dashboard, chart, plot, matplotlib, plotly, seaborn, altair,
bokeh, d3, observable, streamlit, dash, notebooks (`.ipynb`), "figure", "report".

## Commands
```bash
# Notebooks (if used)
jupyter lab                                   # interactive
jupyter nbconvert --to notebook --execute nb.ipynb   # headless re-run

# Python viz app
streamlit run app.py        # or: python -m app  /  python dashboards/main.py

# JS viz app
npm run dev                 # d3/observable/vega dev server
npm run build

# Regenerate figures reproducibly
python scripts/make_figures.py --seed 0 --out figures/
```

## Rules
- code-quality.md, code-review-graph.md (always)
- testing.md (data-transform code; visuals themselves are hard to unit-test)
- Drop database.md unless the viz reads from a DB; drop security.md unless it's a served app.

## Domain rules  → .claude/rules/data-viz.md  (paths: "**/*.ipynb", "notebooks/**", "dashboards/**", "**/plots/**", "**/figures/**")
- Reproducibility first: set explicit random seeds; pin the data snapshot/version a figure was built from; a figure script must regenerate the figure from raw data with no manual steps.
- Separate data wrangling from rendering — keep transform logic in plain modules (testable), not buried in plot calls.
- Use colorblind-safe, perceptually-uniform palettes (viridis/cividis); never red-green as the only signal. Always label axes, units, and legends.
- Don't commit large rendered outputs or raw datasets to git; write them to an ignored `figures/`/`data/` dir and document how to regenerate.
- Strip notebook output + execution counts before committing (nbstripout) to keep diffs reviewable.
- Make charts deterministic: same input + seed → byte-identical output, so diffs mean something.

## Permissions
Allow: `Bash(jupyter *)`, `Bash(streamlit run *)`, `Bash(python scripts/*)`,
`Bash(nbconvert *)`, plus the detected package manager's build/test.

## Gotchas
- "It looks right" is not a test — assert on the underlying transformed data.
- Hardcoded absolute paths to datasets break everyone else's run; use config/relative paths.
