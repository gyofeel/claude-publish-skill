#!/usr/bin/env bash
# publish.sh — first-time publish of a scaffolded skill repo.
#
# Assumes the target dir already contains skills/<name>/SKILL.md, README,
# LICENSE, .gitignore, and — for Claude Code targets only — .claude-plugin/*.json
# (the SKILL.md procedure writes those first). This script owns the
# mechanical git/gh pipeline only — the part that is repetitive and error-prone.
#
# Usage: publish.sh <target_dir> <owner/repo> <version> [description]
#   target_dir   absolute path to the scaffolded repo
#   owner/repo   GitHub slug, e.g. gyofeel/claude-publish-skill
#   version      semver without the leading v, e.g. 0.1.0
#   description  optional repo description (defaults to plugin.json's, else repo name)

set -euo pipefail

TARGET_DIR="${1:?usage: publish.sh <target_dir> <owner/repo> <version> [description]}"
SLUG="${2:?missing owner/repo}"
VERSION="${3:?missing version}"
DESC="${4:-}"

command -v gh >/dev/null || { echo "error: gh CLI not installed"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "error: not logged in — run: gh auth login"; exit 1; }

cd "$TARGET_DIR"
# The one invariant every agent shares. .claude-plugin/ is Claude Code only.
[ -n "$(find skills -maxdepth 2 -name SKILL.md 2>/dev/null)" ] \
  || { echo "error: skills/<name>/SKILL.md missing — scaffold first"; exit 1; }

if [ -z "$DESC" ] && [ -f .claude-plugin/plugin.json ]; then
  DESC="$(node -e "process.stdout.write(require('./.claude-plugin/plugin.json').description||'')")"
fi
DESC="${DESC:-${SLUG##*/}}"

# 1. Validate every JSON file in the repo before publishing.
echo "==> validating JSON"
while IFS= read -r f; do
  node -e "JSON.parse(require('fs').readFileSync('$f','utf8'))" || { echo "invalid JSON: $f"; exit 1; }
  echo "  ok  $f"
done < <(find . -name '*.json' -not -path './.git/*')

# 2. Init repo + first commit on main.
if [ ! -d .git ]; then
  echo "==> git init"
  git init -q
fi
git add -A
if git diff --cached --quiet; then
  echo "==> nothing to commit (already committed)"
else
  git commit -q -m "feat: initial ${SLUG##*/} v${VERSION}

$DESC

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
fi
git branch -M main

# 3. Create the public repo and push. If a plain push later 403s, the git
#    credential helper isn't wired to the gh token — fix and retry.
echo "==> creating public repo $SLUG"
if ! gh repo create "$SLUG" --public --source=. --remote=origin --push --description "$DESC"; then
  echo "==> repo create/push failed — wiring gh credential helper and retrying"
  gh auth setup-git
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$SLUG.git"
  git push -u origin main
fi

# 4. Tag + release. The Releases section stays empty until a release exists,
#    and gh release create needs the tag pushed first.
echo "==> tagging v$VERSION"
git tag -a "v$VERSION" -m "v$VERSION" 2>/dev/null || echo "  tag v$VERSION already exists"
git push origin "v$VERSION"
gh release create "v$VERSION" --title "v$VERSION" --notes "$DESC"

echo "==> done: https://github.com/$SLUG"
gh release view "v$VERSION" --json url -q .url 2>/dev/null || true
