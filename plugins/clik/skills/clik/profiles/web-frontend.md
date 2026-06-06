# Web frontend profile
Match: react, next, vue, svelte, solid, astro, vite, tailwind, shadcn,
`.tsx`/`.jsx`/`.vue`/`.svelte`, "dashboard"/"landing page"/"web app" UI work.

## Commands
```bash
npm run dev            # use the detected pm: pnpm/yarn/bun
npm run build
npm run test           # vitest/jest
npm run test -- <file>
npm run lint
npm run typecheck      # tsc --noEmit
```

## Rules
- code-quality.md, testing.md, code-review-graph.md (always)
- frontend.md (always for this profile) — tailor its component-framework table to the detected stack
- security.md (if it calls APIs / handles auth / takes user input)

## Domain rules  → folded into frontend.md
- Design tokens, not magic values: colors/spacing/typography from the theme, never hardcoded hex/px.
- Accessibility is non-negotiable: semantic HTML, labelled controls, keyboard paths, visible focus, WCAG AA contrast.
- Components stay presentational; data-fetching and state live in hooks/loaders, not JSX.
- No generic "AI-generated" aesthetics — match the project's existing visual language.
- Guard render performance: stable keys, memoize hot lists, avoid unnecessary re-renders.

## Permissions
Allow the detected package manager's `dev`/`build`/`test`/`lint`/`typecheck`
(e.g. `Bash(pnpm *)`, `Bash(bun run *)`), plus git/gh from the template.

## Gotchas
- typecheck + lint after a batch of component edits; TS errors hide in untyped props.
- If the project uses a component registry (shadcn/ui etc.), compose from it — don't hand-roll primitives.
