# `.claude-plugin/plugin.json`

플러그인 자체의 매니페스트. `skills/<name>/`과 같은 repo 루트의 `.claude-plugin/`에 둔다.

## 필드

| 필드 | 설명 |
|---|---|
| `name` | 플러그인/스킬 이름. 소스 스킬 `name`과 동일. 설치 명령의 `<plugin-name>`. |
| `version` | semver. 최초 `0.1.0`. `release.sh`가 bump. |
| `description` | 한 문장. 스킬이 하는 일(영문 권장 — 검색성). |
| `author.name` | GitHub 사용자명. |
| `homepage` / `repository` | repo URL. |
| `license` | 보통 `MIT`. |
| `keywords` | 5~8개 배열. 검색/분류용. |

## 예시

```json
{
  "name": "publish-skill",
  "version": "0.1.0",
  "description": "Package a local Claude Code skill into a public plugin repo and publish it to GitHub — manifests, README, git init, gh repo create, tag + release.",
  "author": {
    "name": "gyofeel"
  },
  "homepage": "https://github.com/gyofeel/claude-publish-skill",
  "repository": "https://github.com/gyofeel/claude-publish-skill",
  "license": "MIT",
  "keywords": ["plugin", "skill", "publish", "release", "github", "gh", "workflow", "automation"]
}
```
