#!/usr/bin/env bash
# release.sh — cut a new version of an already-published skill repo.
#
# Bumps plugin.json version (when present), commits, tags, pushes, and creates
# the GitHub release so the Releases section reflects the new version. Repos
# without .claude-plugin/ (no Claude Code target) carry no version file — for
# those the git tag / GitHub release IS the version.
#
# Usage: release.sh <target_dir> <version> [notes]
#   target_dir   absolute path to the existing repo (has a git remote)
#   version      new semver without the leading v, e.g. 0.2.0
#   notes        optional release notes (defaults to a one-line message)

set -euo pipefail

TARGET_DIR="${1:?usage: release.sh <target_dir> <version> [notes]}"
VERSION="${2:?missing version}"
NOTES="${3:-Release v$2}"

command -v gh >/dev/null || { echo "error: gh CLI not installed"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "error: not logged in — run: gh auth login"; exit 1; }

cd "$TARGET_DIR"
[ -n "$(find skills -maxdepth 2 -name SKILL.md 2>/dev/null)" ] \
  || { echo "error: skills/<name>/SKILL.md missing"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "error: not a git repo"; exit 1; }

if git rev-parse "v$VERSION" >/dev/null 2>&1; then
  echo "error: tag v$VERSION already exists"; exit 1
fi

# Bump version in plugin.json (Node keeps the JSON valid; 2-space indent).
# Only Claude Code targets have one — without it the tag is the sole version
# marker, and `git add` on a missing path would kill the script under set -e.
if [ -f .claude-plugin/plugin.json ]; then
  echo "==> bumping plugin.json to $VERSION"
  node -e "
const fs=require('fs'),p='./.claude-plugin/plugin.json';
const j=JSON.parse(fs.readFileSync(p,'utf8'));
j.version='$VERSION';
fs.writeFileSync(p, JSON.stringify(j,null,2)+'\n');
"
  node -e "JSON.parse(require('fs').readFileSync('./.claude-plugin/plugin.json','utf8'))"

  git add .claude-plugin/plugin.json
  if git diff --cached --quiet; then
    echo "==> plugin.json already at $VERSION"
  else
    git commit -q -m "chore: release v$VERSION

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
  fi
else
  echo "==> no plugin.json — version tracked by the git tag only"
fi
git push origin HEAD

echo "==> tagging v$VERSION"
git tag -a "v$VERSION" -m "v$VERSION"
git push origin "v$VERSION"
gh release create "v$VERSION" --title "v$VERSION" --notes "$NOTES"

echo "==> released v$VERSION"
gh release view "v$VERSION" --json url -q .url 2>/dev/null || true
