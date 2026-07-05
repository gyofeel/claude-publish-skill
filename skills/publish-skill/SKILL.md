---
name: publish-skill
description: >
  로컬 Claude Code 스킬(.claude/skills/<name>/)을 public 플러그인 repo로
  패키징하고 GitHub에 배포하는 파이프라인. 매니페스트(.claude-plugin/plugin.json,
  marketplace.json)·README·LICENSE 작성, git init/commit, gh repo create,
  버전 tag + release 생성까지 자동화한다.
  "이 스킬 public으로 배포해줘", "플러그인으로 만들어 배포", "스킬 퍼블리싱",
  "마켓플레이스에 올려줘", "스킬 버전 올려서 릴리즈" 등 로컬 스킬을 배포/공개/릴리즈하려는
  신호가 있으면 반드시 사용한다.
---

# publish-skill — 로컬 스킬을 public 플러그인으로 배포

## 목적

로컬에서 만든 Claude Code 스킬을 다른 사람이 `/plugin`으로 설치할 수 있는 **public 플러그인 repo**로 만들어 배포한다. 반복되는 기계 작업(매니페스트 스캐폴딩 · git/gh 파이프라인 · tag+release)을 헬퍼 스크립트로 밀고, 판단이 필요한 부분(description·keywords·README)만 사람이 채운다.

핵심: **배포 파이프라인에서 실제로 막히는 지점을 미리 처리한다.** 두 함정이 있다 — (1) 직접 `git push`가 403이면 credential helper가 gh 토큰을 안 쓰는 것(`gh auth setup-git` 필요), (2) tag+release를 따로 만들지 않으면 repo Releases 섹션이 비어 버전 표기가 안 된다. `scripts/publish.sh`가 둘 다 자동 처리한다.

## 어떤 단계로 들어갈지

- "이 스킬 배포/퍼블리시하자" → **최초 배포** (1~4단계 전체).
- "이미 올린 스킬 버전 올려줘 / 릴리즈해줘" → **재배포** (`scripts/release.sh`).

---

## 1단계 — 소스 스킬 파악

배포할 로컬 스킬 디렉토리를 확인한다. 보통 `.claude/skills/<name>/`.

- `SKILL.md`, `references/*`, `evals/*`, `scripts/*` 전부 읽어 구조 파악.
- **깨진 내부 링크 점검** — SKILL.md가 존재하지 않는 `references/xxx.md`를 가리키는지 확인. 있으면 복사본에서 고친다(원본은 건드리지 않음).
- 스킬 프론트매터의 `name`이 배포 이름의 기준.

---

## 2단계 — 메타 확정

플러그인 배포에 필요한 메타를 정한다. 불명확한 것만 사용자에게 소수 질문(추천안 먼저).

| 항목 | 관례/기본값 |
|---|---|
| plugin/skill name | 소스 스킬 `name` 그대로 |
| repo 이름 | `claude-<skill-name>` (기존 관례) |
| marketplace name | repo 이름과 동일 (`claude-<skill-name>`) |
| description | 스킬이 하는 일 한 문장(영문 권장 — 검색성) |
| keywords | 5~8개 |
| author | GitHub 사용자명 |
| version | 기본 `0.1.0` |
| license | MIT |

> **name vs marketplace name 혼동 주의.** `plugin.json.name` = 스킬/플러그인 이름(`publish-skill`). `marketplace.json.name` = 마켓플레이스 이름(`claude-publish-skill`). 설치 명령이 `<plugin-name>@<marketplace-name>` 이라 둘을 섞으면 설치가 깨진다.

---

## 3단계 — 스캐폴딩

기존 플러그인 repo들과 **sibling 디렉토리**에 target을 만든다(예: `~/…/projects/claude-<skill>/`). 새 위치를 임의 발명하지 말고 기존 관례를 따른다.

산출 레이아웃:
```
.claude-plugin/
├── plugin.json          # references/plugin-json.md 참고
└── marketplace.json     # references/marketplace-json.md 참고
skills/<skill-name>/     # 소스 스킬 트리를 cp -R 로 복사
README.md                # references/readme-template.md 골격
LICENSE                  # MIT
.gitignore
```

- 소스 스킬 트리는 `cp -R <src> skills/<skill-name>` 로 통째 복사. **원본은 수정하지 않는다.**
- 매니페스트/README는 references 템플릿을 채워 작성.
- README의 Install 블록은 반드시:
  ```
  /plugin marketplace add <owner>/<repo>
  /plugin install <plugin-name>@<marketplace-name>
  ```

---

## 4단계 — 배포

헬퍼 스크립트에 기계 작업을 맡긴다:

```bash
bash skills/publish-skill/scripts/publish.sh <target_dir> <owner/repo> <version>
```

스크립트가 하는 일: 모든 JSON 검증 → git init/commit/main → `gh repo create --public --push` → (403이면 `gh auth setup-git` 후 재시도) → `v<version>` tag push → `gh release create`.

끝나면 출력의 **repo URL · release URL**을 사용자에게 보고한다. 설치 명령도 함께 안내.

---

## 재배포 — 버전 릴리즈

이미 배포된 스킬을 고쳐 새 버전을 낼 때:

1. 복사본 스킬 파일을 갱신(또는 소스에서 다시 복사).
2. 변경 커밋 후:
   ```bash
   bash skills/publish-skill/scripts/release.sh <target_dir> <new-version>
   ```
   → `plugin.json` version bump + commit + `v<new-version>` tag + `gh release create`.

semver 판단(patch/minor/major)은 사람이 한다.

---

## 하지 말 것

- `plugin.json.name`과 `marketplace.json.name`을 혼동 — 설치 명령이 깨진다.
- tag 없이 `gh release create` 시도 — 스크립트가 tag를 먼저 push하는 이유.
- private로 생성 — public 배포가 목적. `--public` 확인.
- 소스 스킬 원본 수정 — 복사본(target)만 손댄다.
- 매니페스트/README를 임의 새 포맷으로 — references 템플릿과 기존 repo 관례를 따른다.

## references

- [references/plugin-json.md](references/plugin-json.md) — plugin.json 필드 + 예시
- [references/marketplace-json.md](references/marketplace-json.md) — marketplace.json 구조 + 예시
- [references/readme-template.md](references/readme-template.md) — README 골격
