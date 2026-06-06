---
name: code-review-graph-setup
description: Install code-review-graph, wire it into Claude Code, build the knowledge graph, and report graph stats.
argument-hint: ""
disable-model-invocation: true
allowed-tools:
  - Bash(pip *)
  - Bash(pip3 *)
  - Bash(code-review-graph *)
  - Bash(python *)
  - Bash(python3 *)
---

Install and configure code-review-graph for this project.

## Step 1: Check if already installed

```bash
pip show code-review-graph 2>/dev/null || pip3 show code-review-graph 2>/dev/null
```

If installed, skip to Step 3.

If not installed, tell the user:
> "code-review-graph is not installed. Installing now..."

## Step 2: Install

```bash
pip install code-review-graph 2>/dev/null || pip3 install code-review-graph
```

If the install fails, stop and tell the user:
> "Installation failed. Try running `pip install code-review-graph` manually, then re-run /code-review-graph-setup."

Verify the install:
```bash
code-review-graph --version
```

## Step 3: Wire into Claude Code

```bash
code-review-graph install --platform claude-code
```

This registers the MCP server so Claude Code can call graph tools directly. If the command fails with a "platform not found" error, try:
```bash
code-review-graph install
```

and tell the user to manually add the MCP server config to their Claude Code settings.

## Step 4: Build the knowledge graph

```bash
code-review-graph build
```

This parses the codebase with Tree-sitter and builds the structural knowledge graph. It may take 30–90 seconds for large repos. Wait for it to complete.

If it fails with "unsupported language", tell the user the language is not yet supported and check the code-review-graph docs.

## Step 5: Report graph stats

```bash
code-review-graph status
```

Show the output to the user.

## Step 6: Report back

Tell the user:
- Graph built successfully
- The MCP server is wired in — Claude Code will now call graph tools automatically when working near source files
- **They must restart Claude Code for the MCP server registration to take effect**
- After restarting, the graph auto-updates on every file save and git commit — no manual rebuilds needed
- To rebuild manually at any time: `code-review-graph build`
