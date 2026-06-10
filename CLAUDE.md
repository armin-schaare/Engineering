# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This is an experimental repository for authoring and sharing Claude resources: **skills**, **agents**, and **project templates**. There is no build system, test runner, or deployment pipeline — the artifacts here are consumed by Claude Desktop and other Claude Code-compatible applications.

## Repository Structure

- `.claude-plugin/marketplace.json` — Marketplace catalog. Required by Claude Code; lists all published plugins. Update whenever a plugin is added, removed, or version-bumped.
- `plugins/` — Distributable plugin packages. Each plugin is a self-contained directory with a `.claude-plugin/plugin.json` manifest and one or more skills under `skills/<skill-name>/SKILL.md`.
- `skills/` — Standalone skills not yet packaged into a plugin (raw authoring area).
- `agents/` — Agent definitions and configurations.
- `templates/` — Project templates for AI-assisted development, intended to include `AGENTS.md` files, commands, custom tools, and test setups.

## Plugin Layout

```
plugins/<plugin-name>/
  .claude-plugin/
    plugin.json          # name, version, description
  skills/
    <skill-name>/
      SKILL.md           # YAML frontmatter + skill instructions
```

`plugin.json` shape:
```json
{ "name": "...", "version": "1.0.0", "description": "..." }
```

`SKILL.md` shape:
```markdown
---
description: One-line trigger description shown to users.
---

Skill instructions here.
```

## Marketplace Index

`.claude-plugin/marketplace.json` is the single source of truth for what is published. Required fields: `name` (kebab-case marketplace identifier), `owner` (object with `name`), `plugins` (array). Each plugin entry requires `name` and `source` (relative path starting with `./`, or a `github`/`url`/`git-subdir`/`npm` source object).

Bump `version` in both `plugin.json` and the plugin's entry in `marketplace.json` on every release.

Add the marketplace to Claude Code with:
```shell
/plugin marketplace add https://gitlab.com/itemis-ai/skills-agents-and-project-templates.git
```

Validate with `claude plugin validate .` or `/plugin validate .` from the repo root.

## Conventions

**Skills** (`SKILL.md`) use YAML frontmatter for metadata and plain Markdown for instructions. The `description` frontmatter field is used by Claude to decide when to invoke the skill. Plain text only in instructions — no Markdown link syntax for file references.

**Templates** follow the [agents.md](https://agents.md/) convention — include an `AGENTS.md` at the root of each template to give agents context about the project structure and workflow.

**Agents** define reusable agent configurations (instructions, tool access, persona). Document the intended use case and any required environment in the agent's README.