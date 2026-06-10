# Installing a plugin

This guide is for anyone who just wants to **use** the plugin. It covers the one-time SSH
setup needed to reach our GitLab repo, then adding the marketplace and installing the plugin.

> Substitute your real values where you see them:
> - **Repo:** `your-org/your-repo` → our actual GitLab project path
> - **Marketplace name:** `lab-plugins` → the `name` field in `marketplace.json`
> - **Plugin name:** `quality-review-plugin`

---

## 0. Prerequisites

- **Claude Code installed** and up to date. Check with `claude --version`; if `/plugin`
  isn't recognized, update (`brew upgrade claude-code` or
  `npm install -g @anthropic-ai/claude-code@latest`) and restart your terminal.
- **Access to the GitLab repo.** You need the same access you'd need to `git clone` it.
  Adding a marketplace is a `git clone` under the hood.

---

## 1. One-time SSH setup (GitLab)

Claude Code reuses your normal git credentials — it has no separate login. For SSH it
**suppresses the interactive prompts** (the host-fingerprint `yes/no` and the key
passphrase), so your key must already be usable *without* prompting before Claude Code
can use it.

### 1a. Find or create your key

```bash
ls ~/.ssh/
```

Look for a private key (a file **without** `.pub`), e.g. `id_ed25519` or `id_rsa`.
If you don't have one:

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

Then add the **public** key (`~/.ssh/id_ed25519.pub`) to GitLab under
**Profile → Preferences → SSH Keys**.

### 1b. Start the agent and load the key

```bash
eval "$(ssh-agent -s)"          # start the agent if it isn't already running
ssh-add ~/.ssh/id_ed25519       # prompts once for the passphrase, then caches it
```

Verify it's loaded:

```bash
ssh-add -l                      # lists loaded keys
                                # "The agent has no identities" = nothing loaded yet
```

### 1c. Test against GitLab (also seeds `known_hosts`)

```bash
ssh -T git@gitlab.com
```

This should greet you by username. **Importantly, the first run writes `gitlab.com` into
`~/.ssh/known_hosts`** — which is exactly the entry Claude Code needs present, since it
can't answer the fingerprint prompt itself. If `ssh -T` doesn't prompt you and greets you,
you're good.

### 1d. Make it persistent (so you don't re-run `ssh-add` every session)

A plain `eval "$(ssh-agent -s)"` agent only lives for that terminal. To persist:

**macOS** — store the passphrase in Keychain:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

And add to `~/.ssh/config`:

```
Host gitlab.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

(On older macOS the flag is `-K` instead of `--apple-use-keychain`.)

**Linux** — the `AddKeysToAgent yes` line in `~/.ssh/config` usually suffices (the key is
added to the agent the first time it's used). Most desktop environments auto-start an
agent (GNOME Keyring, KWallet). If yours doesn't, add the `eval`/`ssh-add` lines from 1b
to your `~/.bashrc` or `~/.zshrc`.

```
Host gitlab.com
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
```

### The one reliable test

If this works without prompting you, the `/plugin marketplace add` will work too:

```bash
git clone git@gitlab.com:your-org/your-repo.git
```

---

## 2. Add the marketplace

Open a Claude Code session and add the marketplace:

**SSH (recommended given the setup above):**

```
/plugin marketplace add git@gitlab.com:your-org/your-repo.git
```

**HTTPS (if you use HTTPS git credentials instead of SSH):**

```
/plugin marketplace add https://gitlab.com/your-org/your-repo.git
```

> Include the `.git` suffix. A URL ending in `.git` tells Claude Code to **clone the repo**
> (which is what we want). A bare URL to a `marketplace.json` only fetches that one file and
> would break our relative plugin paths.

**Pinning to a specific branch** (e.g. to test an unreleased branch before it's merged):

```
/plugin marketplace add git@gitlab.com:your-org/your-repo.git#branch-name
```

---

## 3. Install and run

```
/plugin install quality-review-plugin@lab-plugins
/reload-plugins
```

The install target is `plugin-name@marketplace-name`. The part after `@` is the
marketplace's `name` field (`lab-plugins`), **not** the repo or folder name.

Run the skill (it's namespaced by plugin name):

```
/quality-review-plugin:quality-review
```

If that fires, you're done.

---

## 4. Updating later

```
/plugin marketplace update lab-plugins   # git pull on the tracked branch + re-resolve
/reload-plugins
```

> While the plugin is still pinned to a fixed `version` in `plugin.json`, new commits
> won't pull until that version string changes. If you're tracking an actively-developed
> branch and want every commit, see the authoring guide's note on omitting `version`.

---

## 5. Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `The agent has no identities` | Key not loaded | Re-run `ssh-add ~/.ssh/id_ed25519`; check `ssh-add -l` |
| SSH `add` fails silently / hangs | `gitlab.com` not in `known_hosts`, or passphrase-locked key | Run `ssh -T git@gitlab.com` once; ensure key is in the agent |
| `marketplace already exists` / stale behavior | You previously added `lab-plugins` from a local `./` path | `/plugin marketplace remove lab-plugins`, then re-add from git |
| Plugin not found after add | Wrong install target | Use `name@marketplace-name`, not the repo slug |
| Skill not appearing | Cache stale | `rm -rf ~/.claude/plugins/cache`, restart, reinstall |
| Updates don't pull new commits | `version` pinned in `plugin.json` | Bump the version, or omit it (git source = every commit is a new version) |
| Auto-update at startup fails (private repo) | Background refresh can't do interactive auth | Export a token: `export GITLAB_TOKEN=glpat-…` (scope `read_repository`) in your shell rc |

### Where does the marketplace actually live?

You don't choose — Claude Code clones it into a per-user directory:

```
~/.claude/plugins/
  known_marketplaces.json        # registry of marketplaces you've added + their sources
  marketplaces/lab-plugins/      # the git clone of the catalog repo
  cache/lab-plugins/quality-review-plugin/<version>/   # the installed, version-pinned copy
```

`/plugin marketplace list` shows each marketplace's source and pinned ref — use it to
confirm you're on the expected branch.

---

## Reference

- Discover & install plugins: <https://code.claude.com/docs/en/discover-plugins>
- Create & distribute a marketplace: <https://code.claude.com/docs/en/plugin-marketplaces>