---
name: skill-vetter
version: 1.0.0
description: Security-first skill vetting for AI agents. Use before installing any skill from ClawHub, GitHub, or other sources. Checks for red flags, permission scope, and suspicious patterns.
---

# Skill Vetter 🔒

Security-first vetting protocol for AI agent skills. **Never install a skill without vetting it first.**

## When to Use

- Before installing any skill from ClawHub
- Before running skills from GitHub repos
- When evaluating skills shared by other agents
- Anytime you're asked to install unknown code

## Vetting Protocol

### Step 1: Source Check

- Where did this skill come from?
- Is the author known/reputable?
- How many downloads/stars does it have?
- When was it last updated?

### Step 2: Code Review (MANDATORY)

Read ALL files in the skill. Check for these **RED FLAGS**:

🚨 REJECT IMMEDIATELY IF YOU SEE:
- curl/wget to unknown URLs
- Sends data to external servers
- Requests credentials/tokens/API keys
- Reads ~/.ssh, ~/.aws, ~/.config without clear reason
- Accesses MEMORY.md, USER.md, SOUL.md, IDENTITY.md
- Uses base64 decode on anything
- Uses eval() or exec() with external input
- Modifies system files outside workspace
- Installs packages without listing them
- Network calls to IPs instead of domains
- Obfuscated code (compressed, encoded, minified)
- Requests elevated/sudo permissions
- Accesses browser cookies/sessions

### Step 3: Permission Scope

- What files does it need to read/write?
- What commands does it run?
- Does it need network access? To where?
- Is the scope minimal for its stated purpose?

### Step 4: Risk Classification

| Risk Level | Examples | Action |
|------------|----------|--------|
| 🟢 LOW | Notes, weather, formatting | Basic review, install OK |
| 🟡 MEDIUM | File ops, browser, APIs | Full code review required |
| 🔴 HIGH | Credentials, trading, system | Human approval required |
| ⛔ EXTREME | Security configs, root access | Do NOT install |

## Output Format

After vetting, produce:

```
SKILL VETTING REPORT
═══════════════════════════════════════
Skill: [name]
Source: [ClawHub / GitHub / other]
Risk Level: [🟢/🟡/🔴/⛔]
Red Flags: [None / List]
Verdict: [✅ SAFE / ⚠️ CAUTION / ❌ REJECT]
═══════════════════════════════════════
```

*Paranoia is a feature.* 🔒
