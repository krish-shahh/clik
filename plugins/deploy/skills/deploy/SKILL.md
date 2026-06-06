---
name: deploy
description: Deploy to Vercel, Railway, Fly.io, or Render. Detects stack, scaffolds config, walks through env vars, and deploys with confirmation.
argument-hint: "[platform: vercel | railway | fly | render — omit to pick interactively]"
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(gh *)
  - Bash(vercel *)
  - Bash(railway *)
  - Bash(flyctl *)
  - Bash(fly *)
  - Read
  - Write
  - Glob
---

Deploy this project to a hosting platform.

## Step 1: Choose a platform

If `$ARGUMENTS` is one of `vercel`, `railway`, `fly`, or `render`, use it.

Otherwise, detect what makes sense from the stack:
- Static site or Next.js / Vite / SvelteKit → **Vercel** (best default)
- Full-stack with database → **Railway** (database bundled)
- Container-based or long-running process → **Fly.io** (best for custom Dockerfiles)
- Simple web service → **Render**

Show the user the recommendation and ask:
> "I recommend [platform] for this stack. Use it, or choose: vercel / railway / fly / render?"

Wait for their choice.

## Step 2: Check the platform CLI is installed

**Vercel**: `vercel --version`
**Railway**: `railway --version`
**Fly**: `fly version` or `flyctl version`
**Render**: no CLI — uses GitHub deploy hooks (handle in Step 4)

If the CLI is not installed, tell the user:
- Vercel: `npm install -g vercel`
- Railway: `npm install -g @railway/cli`
- Fly: `brew install flyctl` or `curl -L https://fly.io/install.sh | sh`

## Step 3: Scaffold platform config (if missing)

**Vercel** (`vercel.json`):
Detect framework (Next.js, Vite, SvelteKit, etc.) and scaffold if no `vercel.json` exists:
```json
{
  "buildCommand": "<detected build command>",
  "outputDirectory": "<detected output dir>",
  "devCommand": "<detected dev command>",
  "installCommand": "<detected install command>"
}
```

**Railway** (`railway.toml`):
```toml
[build]
builder = "nixpacks"

[deploy]
startCommand = "<detected start command>"
restartPolicyType = "on-failure"
restartPolicyMaxRetries = 3
```

**Fly** (`fly.toml`):
Check if `Dockerfile` exists. If not, warn the user — Fly works best with a Dockerfile.
```toml
app = "<repo-name>"
primary_region = "iad"

[build]

[http_service]
  internal_port = <detected port, default 3000>
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
```

**Render**: no config file needed — GitHub integration only. Provide a checklist instead (see Step 4).

Show the config to the user and ask for confirmation before writing.

## Step 4: Env var checklist

Check the codebase for required env vars:
```bash
grep -r "process\.env\." src/ --include="*.ts" --include="*.js" | grep -oP 'process\.env\.\K[A-Z_]+' | sort -u
# or Python:
grep -r "os\.environ\|os\.getenv" . --include="*.py" | grep -oP "(?<=environ\[.)[A-Z_]+|(?<=getenv\(.).+?(?=['\"])" | sort -u
```

Show the user a checklist of detected env vars and ask them to confirm each is set in the platform's dashboard:

```
Required env vars for <platform>:
- [ ] DATABASE_URL
- [ ] NEXTAUTH_SECRET
- [ ] <etc>

Have you set these in the platform dashboard? (yes/no)
```

Wait for confirmation.

## Step 5: Deploy

**Vercel**:
```bash
vercel --prod
```

**Railway**:
```bash
railway up --detach
```

**Fly**:
```bash
fly deploy
```

**Render**:
Tell the user:
> "Render uses GitHub deploys. Go to https://dashboard.render.com → New Web Service → connect your GitHub repo. Use these settings:
> - Build command: `<detected>`
> - Start command: `<detected>`
> - Branch: main"

For CLI-based platforms, stream the deploy output. Wait for it to complete.

## Step 6: Report back

On success:
- Show the deployed URL
- Reminder to check logs if anything looks off:
  - Vercel: `vercel logs`
  - Railway: `railway logs`
  - Fly: `fly logs`
- If this was the first deploy, suggest creating a "Deploy" GitHub Actions step to auto-deploy on push to main
