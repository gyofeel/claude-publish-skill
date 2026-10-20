# publish-skill

A skill that packages a **local skill** (`.claude/skills/<name>/`) into a **public or private repo** and publishes it to GitHub — installable by Claude Code, Cursor, Codex CLI, Gemini CLI, and 70+ other agents.

Turning a local skill into something other people can install is the same handful of mechanical steps every time, with two spots that reliably bite: a plain `git push` that 403s because the git credential helper isn't wired to your `gh` token, and an empty **Releases** section because a tag alone doesn't create a release. This skill bakes both fixes into the pipeline, and asks up front which agents you're targeting so the repo only carries the files those agents actually need.

## Why

- **One command to publish.** Point it at a local skill; it scaffolds the repo, validates the JSON, creates the GitHub repo (public or private), pushes, tags, and releases.
- **Multi-agent by interview.** Pick your targets (Claude Code by default, plus Cursor / Codex CLI / Gemini CLI). `skills/<name>/SKILL.md` is already the universal layout, so the extra cost is install docs — not a second pipeline.
- **Public or private, reviewed.** Before publishing it scans the skill for secrets, internal URLs, org names, personal paths and internal-only dependencies, then recommends public or private with the evidence. Secrets block the publish either way — private is not a fix for a leaked token.
- **Handles the gotchas.** Auto-recovers from the `git push` 403 (`gh auth setup-git`) and always creates a release so the version shows up in the Releases section.
- **Judgment where it matters, automation where it doesn't.** You decide the targets, description, keywords, and README; the helper scripts do the repetitive git/gh work.
- **Version releases too.** Bump an already-published skill with a single `release.sh` call — and it skips the `plugin.json` bump when the repo doesn't have one.

## How it works

1. **Read the source skill** — SKILL.md, references, evals; check for broken internal links, and lint the frontmatter for portability (exact `SKILL.md` filename, `name`/`description` limits, agent-specific fields).
2. **Pick visibility, targets + settle metadata** — public or private (always asked, with a recommendation from the scan), which agents to support, then plugin/skill name, repo name (`claude-<skill>` for Claude-only, `<skill>-skill` when multi-agent), description, keywords, author, version (default `0.1.0`).
3. **Scaffold** — a sibling repo with the skill tree, README, MIT LICENSE (public only), `.gitignore`; `.claude-plugin/` manifests only when Claude Code is a target; Codex's optional `agents/openai.yaml` only if you ask for it.
4. **Publish** — `scripts/publish.sh` validates JSON → `git init`/commit/`main` → `gh repo create --public|--private --push` (with 403 auto-recovery) → tag `vX.Y.Z` + `gh release create`.
5. **Release later** — `scripts/release.sh` bumps `plugin.json` when present, tags, and cuts a new GitHub release.

## Install

Works in any agent that reads `SKILL.md`:

```bash
npx skills add gyofeel/claude-publish-skill
```

Or install as a Claude Code plugin (marketplace updates included):

```
/plugin marketplace add gyofeel/claude-publish-skill
/plugin install publish-skill@claude-publish-skill
```

## Usage

The skill activates on publishing signals — you don't call it directly:

- "이 스킬 public으로 배포해줘" / "Publish this skill" → full first-time publish.
- "private repo로 올려줘" / "Publish it privately for my team" → first-time publish as a private repo.
- "Cursor에도 쓸 수 있게 배포" / "Make it installable in Codex too" → multi-agent publish.
- "스킬 버전 올려서 릴리즈해줘" / "Cut a new version" → `release.sh`.

## What's inside

```
skills/publish-skill/
├── SKILL.md                    # the pipeline — source of truth
├── scripts/
│   ├── publish.sh              # first-time publish (git + gh, 403/releases handled)
│   └── release.sh              # version bump → tag → gh release
└── references/
    ├── providers.md            # per-agent install paths, frontmatter support matrix
    ├── plugin-json.md          # plugin.json fields + example
    ├── marketplace-json.md     # marketplace.json structure + example
    └── readme-template.md      # README skeleton
```

> Note: SKILL.md and references are written in Korean, but the pipeline is language-agnostic.

## Requirements

- [`gh`](https://cli.github.com/) CLI, authenticated (`gh auth login`).
- Node.js — only when the repo carries Claude Code manifests (used for JSON validation).

## License

MIT — see [LICENSE](LICENSE).
