# How we built the plugin & marketplace (from scratch)

For future-me and for anyone who wants to create their own. This walks the full loop:
**create → validate → test locally → push → test from git → ship to the team.**

> Example values used throughout (swap for your own):
> - **Marketplace name:** `itemis-plugins`
> - **Plugin name:** `commit-message-plugin`
> - **Skill name:** `commit-message`
> - **Repo / branch:** `your-org/your-repo` on `create-marketplace`

---

## 1. The mental model (read this first)

Three nested concepts, from inside out:

1. **Components** — the actual capabilities: **skills**, **slash commands**, **subagents**,
   **hooks**, **MCP servers**, **LSP servers**.
2. **Plugin** — a wrapper that bundles one or more components, described by a
   `plugin.json` manifest.
3. **Marketplace** — a *catalog* that lists plugins and where to fetch each one, described
   by a `.claude-plugin/marketplace.json`.

```
component (skill / hook / …)  →  packaged into a plugin  →  listed in a marketplace  →  distributed to people
```

You **install plugins**, not bare skills. A skill reaches a user by riding inside a plugin
(after which it appears namespaced as `/plugin-name:skill-name`).

### Two different "sources" — don't conflate them

- **Marketplace source** — where the *catalog* (`marketplace.json`) is fetched from.
  Set when you run `/plugin marketplace add`. Supports a `ref` (branch/tag), **not** a `sha`.
- **Plugin source** — where each *individual plugin* is fetched from. Set in the `source`
  field of each entry inside `marketplace.json`. Supports both `ref` **and** `sha`.

They can point at completely different repos. A public catalog can list a plugin that lives
in a private repo, and each is fetched/authenticated independently.

> **Bare-skill shortcut (no plugin/marketplace at all):** a skill is just a folder with a
> `SKILL.md`. Dropping it in `~/.claude/skills/<name>/` (personal) or `.claude/skills/<name>/`
> (committed to a repo, shared with the team) makes it work immediately. Lightweight, but
> no versioning, no `/plugin` UI, no auto-update. The plugin/marketplace route is the
> heavyweight, governable channel; raw skills are the "just commit it" channel.

---

## 2. Directory layout

A single repo acting as both the marketplace and the home of one plugin:

```
your-repo/
├── .claude-plugin/
│   └── marketplace.json                      # the catalog → makes this repo a marketplace
└── plugins/
    └── commit-message-plugin/
        ├── .claude-plugin/
        │   └── plugin.json                   # the plugin manifest
        └── skills/
            └── commit-message/
                └── SKILL.md                  # the actual skill
```

Note the two **different** `.claude-plugin/` directories: one at the repo root holds the
*marketplace* catalog; one inside the plugin holds the *plugin* manifest.

---

## 3. Create the files

### 3a. Skeleton

```bash
mkdir -p .claude-plugin
mkdir -p plugins/commit-message-plugin/.claude-plugin
mkdir -p plugins/commit-message-plugin/skills/commit-message
```

### 3b. The marketplace catalog — `.claude-plugin/marketplace.json`

```json
{
  "name": "itemis-plugins",
  "owner": { "name": "Your Name" },
  "plugins": [
    {
      "name": "commit-message-plugin",
      "source": "./plugins/commit-message-plugin",
      "description": "A quick code-review skill"
    }
  ]
}
```

**Required fields:** `name` (kebab-case, public-facing — this is the `@itemis-plugins` part of
the install command), `owner`, and `plugins`. Each plugin entry needs at minimum `name`
and `source`.

> `"source": "./plugins/commit-message-plugin"` is a **relative path**. It resolves only
> because the whole repo is present locally (after a git clone or local `add ./`). It does
> **not** work if the marketplace is added via a bare URL to the JSON file — see §7.

### 3c. The plugin manifest — `plugins/commit-message-plugin/.claude-plugin/plugin.json`

```json
{
  "name": "commit-message-plugin",
  "description": "Adds a commit-message skill for quick code reviews",
  "version": "1.0.0"
}
```

> **Version behavior matters during development.** If `version` is set, users only get
> updates when the string changes — pushing new commits without bumping it does nothing.
> While iterating on a branch, either **bump it every change** or **omit it entirely**; for
> git-based sources, no `version` means every new commit counts as a new version
> automatically. Add a real version back when cutting something stable. Avoid setting
> `version` in *both* `plugin.json` and the marketplace entry — `plugin.json` wins silently.

### 3d. The skill — `plugins/commit-message-plugin/skills/commit-message/SKILL.md`

```markdown
---
description: Review code for bugs, security, and performance
disable-model-invocation: true
---

Review the code I've selected or my recent changes for:
- Potential bugs or edge cases
- Security concerns
- Performance issues
- Readability improvements

Be concise and actionable.
```

`disable-model-invocation: true` makes the skill **manual-only** — Claude won't auto-trigger
it; you invoke it explicitly. Good for a first test because it's deterministic. Remove it
later if you want the skill to be model-invokable based on its `description`.

---

## 4. Validate

Catches JSON typos, bad paths, duplicate names, and version mismatches **before** you try
to install:

```bash
claude plugin validate .
```

(or `/plugin validate .` inside a session). Pointed at a marketplace dir, it checks
`marketplace.json`. Point it at a plugin dir (`claude plugin validate ./plugins/commit-message-plugin`)
to also check the plugin's `plugin.json` and component frontmatter.

---

## 5. Test locally (no push, no commit)

`add ./` reads your working tree, so your branch/commit state doesn't matter yet:

```
/plugin marketplace add ./
/plugin install commit-message-plugin@itemis-plugins
/reload-plugins
/commit-message-plugin:commit-message
```

If the skill fires, the whole chain works. Things to notice:

- Install target is `commit-message-plugin@itemis-plugins` — the `@` part is the
  marketplace's `name`, not a folder.
- The skill is namespaced `/commit-message-plugin:commit-message`, so it won't collide
  with anyone else's `commit-message`.

---

## 6. Test from the branch (the real thing)

```bash
git add -A && git commit -m "Add commit-message plugin + marketplace"
git push -u origin create-marketplace
```

Then **remove the local copy first** (marketplace names are unique per user; re-adding the
same name from a different source causes confusing stale behavior):

```
/plugin marketplace remove itemis-plugins
```

Add it from git, pinned to the branch (`#branch` for git URLs, `@branch` for GitHub
shorthand):

```
/plugin marketplace add git@gitlab.com:your-org/your-repo.git#create-market-place
/plugin install commit-message-plugin@itemis-plugins
/reload-plugins
/commit-message-plugin:commit-message
```

Confirm you're really on the branch with `/plugin marketplace list` (shows source + ref).

Update cycle while iterating:

```
/plugin marketplace update itemis-plugins   # git pull + re-resolve versions
/reload-plugins
```

---

## 7. Plugin source types (beyond relative paths)

Each plugin entry's `source` can be:

| Source | Shape | Notes |
|---|---|---|
| Relative path | `"./plugins/x"` | Same repo; resolves only when repo is cloned. Breaks for bare-JSON-URL marketplaces. |
| `github` | `{ "source": "github", "repo": "org/x", "ref"?, "sha"? }` | Clones over **SSH** (`git@github.com:`) with no HTTPS fallback — see caveat below. |
| `url` | `{ "source": "url", "url": "https://…/x.git", "ref"?, "sha"? }` | Any git host; supports HTTPS **and** SSH. |
| `git-subdir` | `{ "source": "git-subdir", "url": "…", "path": "tools/x", "ref"?, "sha"? }` | Sparse clone of a subdir — good for monorepos. |
| `npm` | `{ "source": "npm", "package": "@org/x", "version"?, "registry"? }` | Installed via `npm install`; supports private registries. |

> **GitHub SSH caveat:** `"source": "github"` clones via SSH only. On a machine with working
> HTTPS but no SSH key, those installs fail. If distributing to a team where SSH keys aren't
> guaranteed, prefer the `url` source with an `https://…​.git` URL. (Not an issue for
> relative-path plugins, which ride along with the marketplace checkout.)

> **Why relative paths break over a bare JSON URL:** adding `https://example.com/marketplace.json`
> fetches only that one file — no surrounding repo, so `./plugins/x` doesn't exist locally.
> Adding a `.git` URL (or `owner/repo`) clones the whole repo, so relative paths resolve.

---

## 8. Ship it to the team

Once merged into the default branch, teammates can add it without the branch suffix:

```
/plugin marketplace add git@gitlab.com:your-org/your-repo.git
/plugin install commit-message-plugin@itemis-plugins
```

### Auto-install for a project (declarative)

Commit this to the project's `.claude/settings.json` so teammates are prompted to install
on trusting the folder. You commit a **pointer**, not the clone — each user clones into
their own `~/.claude/plugins/`.

```json
{
  "extraKnownMarketplaces": {
    "itemis-plugins": {
      "source": { "source": "url", "url": "https://gitlab.com/your-org/your-repo.git" }
    }
  },
  "enabledPlugins": {
    "commit-message-plugin@itemis-plugins": true
  }
}
```

### Install scopes

- **User** (default): for you, across all projects.
- **Project**: shared with collaborators — written to `.claude/settings.json`.
- **Local**: just you, just this repo (not shared).

```
claude plugin install commit-message-plugin@itemis-plugins --scope project
```

### Governance (optional, org-level)

- `strictKnownMarketplaces` in managed settings restricts which marketplaces users may add
  (empty array = lockdown; allowlist by repo/host pattern).
- **Release channels:** stand up two marketplaces pointing at different refs of the same
  repo (e.g. `stable` vs `latest`) and assign them to user groups. Each channel must
  resolve to a *different* version (distinct `version` strings or distinct commit SHAs).

---

## 9. Where things live on disk

```
~/.claude/plugins/
  known_marketplaces.json                     # per-user registry of added marketplaces
  marketplaces/itemis-plugins/                    # the cloned catalog repo
  cache/itemis-plugins/commit-message-plugin/<version>/   # installed plugin, version-pinned
```

Adding a marketplace **clones** into `marketplaces/`. Installing a plugin **copies** it into
the versioned `cache/` — the cache copy is what runs, so a catalog update doesn't silently
change your installed copy until you update. Marketplace state is per-user, even for
project-scoped declarations. Standard "skill won't appear" fix:
`rm -rf ~/.claude/plugins/cache`, restart, reinstall.

---

## 10. Auth recap

- **Manual add/install/update** reuse your existing git credentials:
    - HTTPS via `gh auth login` / Keychain / `git-credential-store`.
    - SSH if `gitlab.com` is in `known_hosts` and the key is loaded in `ssh-agent`
      (Claude Code suppresses fingerprint + passphrase prompts).
- **Background auto-update** (startup) can't prompt, so for **private** repos set a token in
  your shell rc: `GITLAB_TOKEN` / `GL_TOKEN` (GitLab), `GITHUB_TOKEN` / `GH_TOKEN` (GitHub),
  `BITBUCKET_TOKEN` (Bitbucket).
- Auth is checked **twice independently**: once for the marketplace (catalog) repo, once for
  each plugin's `source` repo.

---

## Reference

- Create & distribute a marketplace: <https://code.claude.com/docs/en/plugin-marketplaces>
- Discover & install plugins: <https://code.claude.com/docs/en/discover-plugins>
- Plugins (authoring components): <https://code.claude.com/docs/en/plugins>
- Plugins reference (schemas): <https://code.claude.com/docs/en/plugins-reference>