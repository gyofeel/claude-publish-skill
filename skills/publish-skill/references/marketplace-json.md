# `.claude-plugin/marketplace.json`

마켓플레이스 매니페스트. `/plugin marketplace add <owner>/<repo>` 가 이 파일을 읽어 설치 가능한 플러그인 목록을 안다. 단일 스킬 repo면 `plugins` 배열에 항목 1개.

## 필드

| 필드 | 설명 |
|---|---|
| `name` | **마켓플레이스** 이름. repo 이름과 동일(`claude-<skill>`). 설치 명령의 `<marketplace-name>`. `plugin.json.name`과 다르다. |
| `metadata.description` | 마켓플레이스 한 줄 설명. |
| `owner.name` | GitHub 사용자명. |
| `plugins[]` | 이 마켓플레이스가 제공하는 플러그인 목록. |
| `plugins[].name` | `plugin.json.name`과 일치. |
| `plugins[].source` | 플러그인 위치. repo 루트면 `"./"`. |
| `plugins[].category` | 예: `productivity`. |
| `plugins[].homepage` | repo URL. |

## 설치 명령의 이름 대응

```
/plugin marketplace add <owner>/<repo>
/plugin install <plugins[].name>@<marketplace .name>
```
→ 예: `/plugin install publish-skill@claude-publish-skill`

## 예시

```json
{
  "name": "claude-publish-skill",
  "metadata": {
    "description": "Publish a local Claude Code skill as a public plugin: scaffold manifests, git init, gh repo create, tag + release."
  },
  "owner": {
    "name": "gyofeel"
  },
  "plugins": [
    {
      "name": "publish-skill",
      "description": "Package and publish a local skill to GitHub as an installable Claude Code plugin.",
      "author": {
        "name": "gyofeel"
      },
      "source": "./",
      "category": "productivity",
      "homepage": "https://github.com/gyofeel/claude-publish-skill"
    }
  ]
}
```
