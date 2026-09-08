---
name: publish-skill
description: >
  로컬 스킬(.claude/skills/<name>/)을 public repo로 패키징하고 GitHub에 배포하는
  파이프라인. 인터뷰로 타깃 에이전트(Claude Code / Cursor / Codex CLI / Gemini CLI)를
  정하고, 그에 맞는 매니페스트(.claude-plugin/plugin.json, marketplace.json)·README·
  LICENSE 작성, git init/commit, gh repo create, 버전 tag + release 생성까지 자동화한다.
  "이 스킬 public으로 배포해줘", "플러그인으로 만들어 배포", "스킬 퍼블리싱",
  "마켓플레이스에 올려줘", "스킬 버전 올려서 릴리즈", "Cursor에도 쓸 수 있게 배포",
  "멀티 프로바이더로 배포", "Codex/Gemini에서도 되게", "npx skills add로 설치되게" 등
  로컬 스킬을 배포/공개/릴리즈하려는 신호가 있으면 반드시 사용한다.
---

# publish-skill — 로컬 스킬을 public repo로 배포

## 목적

로컬에서 만든 스킬을 다른 사람이 설치할 수 있는 **public repo**로 만들어 배포한다. 반복되는 기계 작업(매니페스트 스캐폴딩 · git/gh 파이프라인 · tag+release)을 헬퍼 스크립트로 밀고, 판단이 필요한 부분(타깃 에이전트·description·keywords·README)만 사람이 채운다.

핵심: **배포 파이프라인에서 실제로 막히는 지점을 미리 처리한다.** 두 함정이 있다 — (1) 직접 `git push`가 403이면 credential helper가 gh 토큰을 안 쓰는 것(`gh auth setup-git` 필요), (2) tag+release를 따로 만들지 않으면 repo Releases 섹션이 비어 버전 표기가 안 된다. `scripts/publish.sh`가 둘 다 자동 처리한다.

또 하나: **`skills/<name>/SKILL.md` 레이아웃은 이미 범용이다.** Cursor·Codex CLI·Gemini CLI가 같은 포맷을 읽고 `npx skills add`가 70+ 에이전트에 설치한다. 멀티 에이전트 배포는 새 파이프라인이 아니라 **설치 문서 + Claude 전용 파일의 조건부화**다.

## 어떤 단계로 들어갈지

- "이 스킬 배포/퍼블리시하자" → **최초 배포** (1~4단계 전체).
- "이미 올린 스킬 버전 올려줘 / 릴리즈해줘" → **재배포** (`scripts/release.sh`).
- "이미 배포한 스킬에 Cursor/Codex 추가해줘" → **에이전트 추가** (재배포 섹션 하위 참고).

---

## 1단계 — 소스 스킬 파악

배포할 로컬 스킬 디렉토리를 확인한다. 보통 `.claude/skills/<name>/`.

- `SKILL.md`, `references/*`, `evals/*`, `scripts/*` 전부 읽어 구조 파악.
- **깨진 내부 링크 점검** — SKILL.md가 존재하지 않는 `references/xxx.md`를 가리키는지 확인. 있으면 복사본에서 고친다(원본은 건드리지 않음).
- 스킬 프론트매터의 `name`이 배포 이름의 기준.
- **이식성 점검(린트) — 재료만 모으고 판단은 2단계에서.**
  - 파일명이 **정확히 `SKILL.md`** 인가. `skill.md`/`Skill.md`는 Gemini CLI·Antigravity가 대소문자 구분 FS에서 경고 없이 건너뛴다 → 다르면 복사본에서 고친다.
  - `name`이 kebab-case ≤64자, `description` ≤1024자인가 → 넘으면 복사본에서 줄인다.
  - `allowed-tools`·`context`·`model`·`paths` 같은 **에이전트 전용 필드**가 있는지 기록. 지원 여부는 [references/providers.md](references/providers.md)의 매트릭스로 판단한다.

---

## 2단계 — 타깃 에이전트 + 메타 확정

배포에 필요한 것을 정한다. 불명확한 것만 사용자에게 소수 질문(추천안 먼저).

**Q1. 어디에서 설치 가능하게 할까?**

- **Claude Code — 기본 ON.** 유일하게 생성 파일이 필요한 에이전트(`.claude-plugin/` 매니페스트).
- 추가로 고를 수 있음: **Cursor** / **Codex CLI** / **Gemini CLI**. 셋 다 추가 파일이 0개이고, README 설치 안내 행만 늘어난다.
- `npx skills add <owner>/<repo>` 줄은 **선택과 무관하게 항상** README에 넣는다. 비용이 한 줄이고 70+ 에이전트에서 유효하다.

**Q2 (Codex를 골랐을 때만). Codex UI 메타(`agents/openai.yaml`)를 넣을까?** 기본 **아니오** — 선택 파일이고 아이콘 에셋이 없으면 실익이 없다. "예"면 `display_name` + `short_description` 두 줄만 쓴다.

**Q3. 린트 결과 보고.** 1단계에서 모은 전용 필드를 Q1 선택과 대조해 "어느 에이전트가 이걸 무시하는지" 표로 보여준다.

- 기본 권고는 **그대로 둔다** — 미지원 필드는 에러가 아니라 조용한 무시다. 지우면 Claude Code 경로만 손해다.
- 제거를 권하는 유일한 경우: **Claude Code를 선택하지 않았는데 Claude 전용 필드가 남아 있을 때** (순수 사표).
- 스킬이 그 필드에 기능적으로 의존하면(예: `context: fork` 전제의 서브에이전트 동작) 지우지 말고 **"Cursor에서는 이 동작이 안 난다"고 경고**한다.
- 어떤 수정이든 **복사본에만** 적용한다.

메타 표:

| 항목 | 관례/기본값 |
|---|---|
| plugin/skill name | 소스 스킬 `name` 그대로 |
| repo 이름 | Claude 단독 → `claude-<skill-name>` (기존 관례) / 멀티 에이전트 → `<skill-name>-skill`. 추천으로 제시하고 사용자가 덮어쓸 수 있게 |
| marketplace name | repo 이름과 동일. **Claude Code 선택 시에만 존재** |
| description | 스킬이 하는 일 한 문장(영문 권장 — 검색성) |
| keywords | 5~8개 |
| author | GitHub 사용자명 |
| version | 기본 `0.1.0` |
| license | MIT |

> **name vs marketplace name 혼동 주의** (Claude Code를 선택한 경우에만 해당). `plugin.json.name` = 스킬/플러그인 이름(`publish-skill`). `marketplace.json.name` = 마켓플레이스 이름(`claude-publish-skill`). 설치 명령이 `<plugin-name>@<marketplace-name>` 이라 둘을 섞으면 설치가 깨진다.

---

## 3단계 — 스캐폴딩

기존 플러그인 repo들과 **sibling 디렉토리**에 target을 만든다(예: `~/…/projects/claude-<skill>/`). 새 위치를 임의 발명하지 말고 기존 관례를 따른다.

산출 레이아웃 — **항상 만드는 것**:
```
skills/<skill-name>/     # 소스 스킬 트리를 cp -R 로 복사. 이게 범용 레이아웃 본체
README.md                # references/readme-template.md 골격
LICENSE                  # MIT
.gitignore
```

**Claude Code를 선택했을 때만**:
```
.claude-plugin/
├── plugin.json          # references/plugin-json.md 참고
└── marketplace.json     # references/marketplace-json.md 참고
```

**Codex 선택 + Q2가 "예"일 때만**:
```
skills/<skill-name>/agents/openai.yaml   # references/providers.md 참고
```

- 소스 스킬 트리는 `cp -R <src> skills/<skill-name>` 로 통째 복사. **원본은 수정하지 않는다.**
- 매니페스트/README는 references 템플릿을 채워 작성.
- README의 Install 섹션은 [references/readme-template.md](references/readme-template.md)의 Install 블록을 **선택한 에이전트만 남겨** 채운다. `npx skills add` 줄은 항상 유지.

> **Cursor·Gemini CLI는 추가 파일이 0개다.** `skills/<name>/SKILL.md` 자체가 그들이 읽는 포맷이다. 프로바이더별 디렉토리(`.cursor/skills/`, `.agents/skills/`)를 repo 안에 미러링하지 않는다 — 중복이고 설치 시점에 도구가 알아서 배치한다.

---

## 4단계 — 배포

헬퍼 스크립트에 기계 작업을 맡긴다:

```bash
bash skills/publish-skill/scripts/publish.sh <target_dir> <owner/repo> <version> [description]
```

스크립트가 하는 일: 모든 JSON 검증 → git init/commit/main → `gh repo create --public --push` → (403이면 `gh auth setup-git` 후 재시도) → `v<version>` tag push → `gh release create`.

> Claude Code를 선택하지 않아 `plugin.json`이 없으면 **description을 4번째 인자로 넘긴다.** 스크립트가 plugin.json에서 읽을 수 없어서, 안 넘기면 repo 이름으로 폴백한다.

끝나면 출력의 **repo URL · release URL**을 사용자에게 보고한다. 설치 명령도 함께 안내하되, **선택한 에이전트의 것만** 안내한다.

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

- repo 이름·marketplace 이름은 **절대 안 바꾼다** — 기존 설치가 전부 깨진다.
- `plugin.json`이 없는 repo(Claude Code 미포함)면 버전은 **git tag/release가 전부**. `release.sh`가 bump를 알아서 건너뛴다.
- 소스에서 다시 복사할 때 target 전용 변경(`agents/openai.yaml`, 고친 내부 링크, 조정한 프론트매터)이 덮이지 않게 주의.

### 이미 배포한 repo에 에이전트 추가

1. repo 이름은 **바꾸지 않는다**. 이름은 최초 배포 때 한 번 정해지고 동결된다.
2. Cursor / Gemini CLI / 롱테일 추가 → **README Install 표에 행 추가뿐.**
3. Codex 추가 + UI 메타를 원하면 → `skills/<name>/agents/openai.yaml` 1개 추가.
4. Claude Code를 새로 추가 → 2단계 메타 표를 채워 `.claude-plugin/plugin.json` + `marketplace.json` 신규 작성. `marketplace.json.name`은 **이미 존재하는 repo 이름**을 쓴다(새로 짓지 않는다).
5. 커밋 후 `release.sh <target_dir> <minor bump>` — 기능 추가이므로 minor.

---

## 하지 말 것

- `plugin.json.name`과 `marketplace.json.name`을 혼동 — 설치 명령이 깨진다.
- tag 없이 `gh release create` 시도 — 스크립트가 tag를 먼저 push하는 이유.
- private로 생성 — public 배포가 목적. `--public` 확인.
- 소스 스킬 원본 수정 — 복사본(target)만 손댄다.
- 매니페스트/README를 임의 새 포맷으로 — references 템플릿과 기존 repo 관례를 따른다.
- 배포 repo 안에 `.cursor/skills/`·`.agents/skills/` 미러 생성 — 설치 시점에 결정될 일이다.
- 이미 배포된 repo 이름 변경 — `/plugin marketplace add`와 기존 설치가 전부 깨진다.
- 선택하지 않은 에이전트를 README에 문서화 — 검증 안 한 걸 적지 않는다.

## references

- [references/providers.md](references/providers.md) — 에이전트별 설치 경로 · frontmatter 지원 매트릭스 · openai.yaml
- [references/plugin-json.md](references/plugin-json.md) — plugin.json 필드 + 예시
- [references/marketplace-json.md](references/marketplace-json.md) — marketplace.json 구조 + 예시
- [references/readme-template.md](references/readme-template.md) — README 골격
