# Building a full-stack web app with clik

A complete walkthrough using a real example: **TaskFlow**, a simple project management SaaS. Stack: Next.js 14, TypeScript, Prisma + PostgreSQL, Clerk auth, Tailwind CSS, deployed to Vercel.

---

## Prerequisites

Before starting any project:

- Claude Code installed and open
- `gh auth login` done — GitHub CLI authenticated
- clik installed: enable the `clik` plugin at user scope ([see README](https://github.com/krish-shahh/clik#install-once-for-all-projects)), then run `/clik` in your project

---

## 1. Start the project

Open a new empty folder in Claude Code. Run:

```
/init-project
```

Claude will ask if you want to create a new GitHub repo or connect an existing one. Say **new**, give it a name (`taskflow`), choose public or private. It scaffolds `CLAUDE.md` with blank Stack/Commands/Architecture/Active Issue sections, commits, and pushes.

> **Next step it tells you**: run `/clik` to tailor the config — but first write a PRD so the planning step has something to work from.

---

## 2. Write a PRD with plan mode

You have an idea but no spec. Use plan mode to turn it into a document before planning issues.

Hit **Shift+Tab** to enter plan mode. Then type:

```
Write a PRD.md for TaskFlow — a project management SaaS where teams 
can create projects, break them into tasks, assign tasks to members, 
and track progress on a Kanban board. Next.js frontend, Postgres 
database, Clerk for auth, deploy to Vercel.
```

Claude outlines what it will write. Review the plan — check it covers must-haves, nice-to-haves, constraints, and out-of-scope. Approve it.

Claude writes `PRD.md`. **Read it.** Edit anything that's wrong — add a constraint you forgot, cut a feature that's out of scope for v1, clarify an ambiguity. This document drives everything downstream so it's worth 5 minutes now.

Your `PRD.md` should end up looking roughly like:

```markdown
# PRD: TaskFlow

## Goal
A lightweight project management tool for small teams. Teams create 
projects, break work into tasks, assign owners, and track status on 
a Kanban board.

## Must-haves (v1)
- User auth (sign up, sign in, sign out) via Clerk
- Create and manage projects
- Create tasks within projects (title, description, status, assignee)
- Kanban board view (Todo / In Progress / Done columns)
- Invite team members to a project

## Nice-to-haves
- Due dates and reminders
- Activity feed per project
- File attachments on tasks

## Technical constraints
- Next.js 14 App Router, TypeScript, Tailwind CSS
- Prisma ORM + PostgreSQL (Railway for DB)
- Clerk for authentication
- Deploy to Vercel
- Target: under 200ms p95 API response time

## Out of scope (v1)
- Mobile app
- Time tracking
- Integrations (Slack, GitHub, etc.)
- Custom fields

## Open questions
- Do guests (non-members) get read-only access to public projects?
- What's the max team size per project for v1?
```

---

## 3. Tailor the project, then plan the work into GitHub issues

First, point `/clik` at the project so its config matches the stack:

```
/clik next.js app with prisma, clerk auth, deployed on vercel
```

Claude writes a lean `CLAUDE.md` (real `pnpm` commands), the relevant rules (frontend, security, database, error-handling — path-scoped), and permissions for the toolchain.

Then plan the build. Ask `@architect` to break the PRD into phased, shippable issues:

```
@architect "read PRD.md and break v1 into phased GitHub issues — Phase 1 
foundation, Phase 2 core features, Phase 3 polish. Each issue independently 
shippable with 3-5 acceptance criteria. Constraints: Next.js, Prisma, Clerk, 
Vercel, Railway for DB."
```

You'll get a phased plan like:

```
Phase 1 — Foundation
  [P1/M] Set up Next.js project with TypeScript and Tailwind
  [P1/M] Configure Prisma + PostgreSQL schema (users, projects, tasks, memberships)
  [P1/S] Add Clerk authentication (sign in, sign up, middleware)
  [P1/S] Set up GitHub Actions CI (typecheck + lint + test on every PR)

Phase 2 — Core features
  [P1/L] Projects CRUD API and UI
  [P1/L] Tasks CRUD API and UI
  [P2/L] Kanban board view
  ...
```

Review and adjust it in chat. Once you're happy, have Claude create the issues directly:

```
Create these as GitHub issues with gh, each with its acceptance criteria 
as a checklist. Start with Phase 1.
```

Claude runs `gh issue create` for each, then tells you:

> "Phase 1 issues created: #1, #2, #3, #4. Run `/start-issue 1` to begin."

---

## 4. Set up CI before writing code

```
/setup-ci
```

Claude detects Next.js + TypeScript and scaffolds `.github/workflows/ci.yml` with typecheck, lint, and test jobs. Confirms, commits, pushes. Every PR now has a CI gate before merge.

---

## 5. Work through issues one at a time

Repeat this loop for each issue.

### Pick up the issue

```
/start-issue 1
```

Claude fetches issue #1, checks for blockers (none), creates `feature/issue-1-nextjs-setup` from latest main, pushes it, and updates `## Active Issue` in `CLAUDE.md`. It prints the acceptance criteria as a checklist so you know exactly what done looks like.

Every time you open Claude Code on this branch from now on, `session-start.sh` automatically injects the issue body into context. You don't have to re-explain what you're working on.

Juggling more than one issue at a time? Add `--worktree` (`/start-issue 1 --worktree`) and Claude puts the issue in its own isolated working copy (`../taskflow-issue-1`) so you can work several in parallel without stashing and leave your main checkout untouched. Run `git worktree remove` after it merges.

### For simple issues — just build

Issue #1 is "Set up Next.js project". It's mechanical. Just tell Claude what to do:

```
Initialize a Next.js 14 app with TypeScript, Tailwind, and the App Router. 
Add ESLint and Prettier. No src/ directory.
```

Or use plan mode if you want to review before files get created:

**Shift+Tab** → describe what you want → review the list of files Claude plans to create → approve.

### For complex issues — use @architect first

Issue #6 is "Tasks CRUD API and UI". Before writing any code, get a concrete plan:

```
@architect "implement tasks CRUD — create, read, update, delete tasks 
within a project. Each task has title, description, status 
(todo/in-progress/done), and assignee."
```

`@architect` explores the existing codebase — reads the Prisma schema, the projects API you already built, the auth middleware — and returns:

```
## Affected files
Create: app/api/tasks/route.ts, app/api/tasks/[id]/route.ts,
        app/projects/[id]/tasks/page.tsx,
        components/TaskCard.tsx, components/TaskForm.tsx,
        lib/tasks.ts
Modify: prisma/schema.prisma (Task model already exists, add indexes)
        app/projects/[id]/page.tsx (add tasks list)

## API contract
POST   /api/tasks          body: { title, projectId, assigneeId? }
GET    /api/tasks?project= 
PATCH  /api/tasks/:id      body: { title?, status?, assigneeId? }
DELETE /api/tasks/:id

## Implementation steps
1. Add missing DB indexes to Task model, run migration
2. Build task service functions in lib/tasks.ts
3. Build API routes with auth middleware + project membership checks
4. Build TaskForm component (create/edit)
5. Build TaskCard component (status badge, assignee avatar)
6. Wire into project page

## Risks
- IDOR: task endpoints must verify user is a project member before 
  read/write — existing projects middleware handles this pattern
- Status enum: make sure Prisma enum matches frontend constants
```

Now you understand exactly what to build. Use this as your implementation guide.

**Shift+Tab** → "implement step 1 and 2 from the architect plan" → review → approve.

Build one step at a time through the architect plan. Plan mode before each step if you want visibility, or just describe the step directly for straightforward work.

### Write tests

Once the feature is built, `/test-writer` triggers automatically on new code, mapping every path — happy, edge, error, concurrency — and verifying the tests actually catch bugs. For a test-first flow instead, drive it with `/tdd`:

```
/tdd "tasks CRUD — create/read/update/delete within a project"
```

Red (failing test) → green (minimum code) → refactor, committing after each cycle.

If a test is red for a non-obvious reason, run `/debug-fix "3 tests failing in tasks.test.ts — [paste failure output]"` for a careful reproduce-investigate-fix pass.

### Review before merging

```
/pr-review
```

Claude calls `detect_changes_tool` to get the blast radius, then fans out to specialist agents in parallel:

- `@code-reviewer` — always runs
- `@security-reviewer` — runs because the tasks API touches auth and DB queries
- `@performance-reviewer` — runs because there are DB queries in the API routes

You get a synthesized report. Address any findings, then:

### Close the issue

```
/done
```

Claude:
1. Parses acceptance criteria from issue #6
2. Checks each one against the git diff (✅ / ⚠️ / ❌)
3. Gets blast radius from `detect_changes_tool` and test gaps from `get_knowledge_gaps_tool`
4. Drafts a completion comment — shows it to you for review
5. Posts the comment, closes issue #6
6. Clears `## Active Issue` in `CLAUDE.md`
7. Pushes the branch and opens a PR
8. Shows you the remaining open issues

> "Issue #6 closed. Remaining open: #7 Kanban board, #8 Invitations, #9 Access control. Run `/start-issue 7` to continue."

---

## 6. Repeat

Pick up issue #7:

```
/start-issue 7
```

For the Kanban board, use `@architect` again — it's a UI-heavy feature with drag-and-drop state. The architect will check what component library you're using (from the existing code), propose the state management approach, flag which existing components to extend vs replace.

Build → `/test-writer` → `/pr-review` → `/done`.

---

## 7. Deploy when Phase 1 and 2 are done

```
/deploy vercel
```

Claude detects Next.js, checks for `vercel.json` (creates one if missing), scans the codebase for `process.env.*` calls, and gives you a checklist:

```
Required env vars for Vercel:
- [ ] DATABASE_URL
- [ ] NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
- [ ] CLERK_SECRET_KEY
- [ ] NEXT_PUBLIC_APP_URL

Have you set these in the Vercel dashboard? (yes/no)
```

Confirm, and it runs `vercel --prod`. Shows the deployed URL.

---

## 8. Daily maintenance

**Start of day:**
```
/standup
```
Outputs yesterday's commits, closed issues, open PRs, and any blockers. Paste it into Slack.

**Random error in CI:**
```
/debug-fix "TypeError: Cannot read property 'id' of undefined 
in lib/tasks.ts:47"
```

**Something's broken and you don't know why:**
```
/debug-fix "tasks aren't loading on the project page after the 
recent auth middleware change"
```

---

## Summary: the full loop

```
Shift+Tab → "write PRD.md"     idea → spec
/clik <project context>        tailor config to the stack
@architect "plan PRD → issues" spec → GitHub issues (gh issue create)
/setup-ci                      CI from day one

for each issue:
  /start-issue N               load context, create branch
  @architect (complex only)    understand what to build
  Shift+Tab → "build step X"   execution plan before edits
  ... build ...
  /test-writer (auto)          tests
  /pr-review                   review
  /done                        close, PR, next issue

/deploy vercel                 ship it
/standup                       daily
```

---

## When to use plan mode vs not

| Situation | What to do |
|-----------|-----------|
| Starting something from scratch | Shift+Tab → describe it |
| Multi-file feature, approach unclear | `@architect` first, then Shift+Tab per step |
| Simple bug fix or small addition | Just describe it directly, no plan mode needed |
| Refactor across many files | `/refactor` handles this — has its own safety steps |
| Tests needed | `/test-writer` (auto-triggers) or `/tdd` — no plan mode needed |
| Emergency production bug | `/debug-fix --fast` |
