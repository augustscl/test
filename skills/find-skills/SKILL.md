---
name: find-skills
description: Helps users discover and install agent skills when they ask questions like "how do I do X", "find a skill for X", "is there a skill that can...", or express interest in extending capabilities. This skill should be used when the user is looking for functionality that might exist as an installable skill.
---

# Find Skills

This skill helps you discover and install skills from the open agent skills ecosystem.

## When to Use This Skill

Use this skill when the user:

- Asks "how do I do X" where X might be a common task with an existing skill
- Says "find a skill for X" or "is there a skill for X"
- Asks "can you do X" where X is a specialized capability
- Expresses interest in extending agent capabilities
- Wants to search for tools, templates, or workflows

## How to Help Users Find Skills

### Step 1: Search for Skills

```bash
clawhub search [query]
```

### Step 2: Inspect Before Installing

```bash
clawhub inspect <slug> --files
clawhub inspect <slug> --file <path>
```

### Step 3: Install

```bash
clawhub install <slug>
```

**Browse skills at:** https://clawhub.com/

## Tips

1. Use specific keywords: "react testing" > "testing"
2. Try alternative terms if first search misses
3. Always vet/audit before installing (see skill-vetter)
4. If no skill found, offer to help directly or create one
