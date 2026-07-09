# itemis Claude-Plugins: Engineering

Claude Code skills for daily development/engineering workflows — source control and code review.

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
```

## What It Does

- **Source control** — draft conventional commit messages from staged or unstaged changes
- **Code review** — technically focused code review with configurable scope (branch diff, commit range, specific paths); optionally post inline comments to GitLab MRs

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

## Contributing

See the shared [CONTRIBUTING.md](https://gitlab.com/itemis/itemis-ai/claude-plugins/commons/-/blob/main/CONTRIBUTING.md) in the `commons` repository for the dev setup and instructions for testing and publishing changes.

## License

Proprietary. All rights reserved. See [LICENSE](LICENSE) for details.
