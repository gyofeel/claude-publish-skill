# publish-skill

A Claude Code plugin that packages a **local skill** (`.claude/skills/<name>/`) into a **public plugin repo** and publishes it to GitHub — manifests, README, `git init`, `gh repo create`, and version tag + release, in one pass.

Turning a local skill into an installable plugin is the same handful of mechanical steps every time, with two spots that reliably bite: a plain `git push` that 403s because the git credential helper isn't wired to your `gh` token, and an empty **Releases** section because a tag alone doesn't create a release. This skill bakes both fixes into the pipeline.

## Why

- **One command to publish.** Point it at a local skill; it scaffolds the plugin repo, validates the JSON, creates the public GitHub repo, pushes, tags, and releases.
- **Handles the gotchas.** Auto-recovers from the `git push` 403 (`gh auth setup-git`) and always creates a release so the version shows up in the Releases section.
- **Judgment where it matters, automation where it doesn't.** You decide the description, keywords, and README; the helper scripts do the repetitive git/gh work.
- **Version releases too.** Bump an already-published plugin to a new version with a single `release.sh` call.

## How it works

1. **Read the source skill** — SKILL.md, references, evals; check for broken internal links.
2. **Settle metadata** — plugin/skill name, repo name (`claude-<skill>` convention), description, keywords, author, version (default `0.1.0`).
3. **Scaffold** — a sibling plugin repo with `.claude-plugin/` manifests, a copy of the skill tree, README, MIT LICENSE, `.gitignore`.
4. **Publish** — `scripts/publish.sh` validates JSON → `git init`/commit/`main` → `gh repo create --public --push` (with 403 auto-recovery) → tag `vX.Y.Z` + `gh release create`.
5. **Release later** — `scripts/release.sh` bumps `plugin.json`, tags, and cuts a new GitHub release.

## Install

In Claude Code:

```
/plugin marketplace add gyofeel/claude-publish-skill
/plugin install publish-skill@claude-publish-skill
```

## Usage

The skill activates on publishing signals — you don't call it directly:

- "이 스킬 public으로 배포해줘" / "Publish this skill as a plugin" → full first-time publish.
- "스킬 버전 올려서 릴리즈해줘" / "Cut a new version" → `release.sh`.

## What's inside

```
skills/publish-skill/
├── SKILL.md                    # the pipeline — source of truth
├── scripts/
│   ├── publish.sh              # first-time publish (git + gh, 403/releases handled)
│   └── release.sh              # version bump → tag → gh release
└── references/
    ├── plugin-json.md          # plugin.json fields + example
    ├── marketplace-json.md     # marketplace.json structure + example
    └── readme-template.md      # README skeleton
```

> Note: SKILL.md and references are written in Korean, but the pipeline is language-agnostic.

## Requirements

- [`gh`](https://cli.github.com/) CLI, authenticated (`gh auth login`).
- Node.js (used for JSON validation).

## License

MIT — see [LICENSE](LICENSE).
