# itemis Claude-Plugins: Engineering

Claude Code skills for daily development/engineering workflows — source control, code review, and token-efficient communication.

- [Installation](#installation)
- [What It Does](#what-it-does)
- [Skills](#skills)
- [Contributing](#contributing)
- [License](#license)

## Installation

For the general installation workflow, see the [commons README](https://gitlab.com/itemis/itemis-ai/claude-plugins/commons/-/blob/main/README.md#plugin-installation).

```shell
/plugin marketplace add https://gitlab.com/itemis/itemis-ai/claude-plugins/skills-agents-and-project-templates.git
```

```shell
/plugin install git@engineering
/plugin install review@engineering
/plugin install caveman@engineering
```

## What It Does

- **Source control** — draft conventional commit messages from staged or unstaged changes
- **Code review** — technically focused code review with configurable scope (branch diff, commit range, specific paths); optionally post inline comments to GitLab MRs
- **Caveman mode** — ultra-compressed communication that cuts token usage ~75% while keeping full technical accuracy

## Skills

### Source Control

| Skill | Description |
| --- | --- |
| `make-msg` | Generate a conventional commit message from staged or unstaged changes. Activates when asked to write, draft, or suggest a commit message. |

### Code Review

| Skill | Description |
| --- | --- |
| `/review-technical` | Technically focused code review with configurable scope: branch diff vs main, commit range, specific paths/feature, or whole project. Activates when the user asks to review code, check changes, or sanity-check a diff. |
| `/submit-suggestions` | Post review findings as inline comments on a GitLab merge request, one at a time with user confirmation. Activates when the user wants to push review results to an MR. |

### Productivity

| Skill | Description |
| --- | --- |
| `caveman` | Ultra-compressed communication mode. Cuts token usage ~75% by dropping filler, articles, and pleasantries while keeping full technical accuracy. Activates when the user says "caveman mode" or invokes `/caveman`. |

## Contributing

See the shared [CONTRIBUTING.md](https://gitlab.com/itemis/itemis-ai/claude-plugins/commons/-/blob/main/CONTRIBUTING.md) in the `commons` repository for the dev setup and instructions for testing and publishing changes.

## License

Proprietary. All rights reserved. See [LICENSE](LICENSE) for details.
