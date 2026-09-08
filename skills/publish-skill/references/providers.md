# 프로바이더별 배포 정보

`SKILL.md`는 이제 크로스 에이전트 포맷이다. **이 스킬이 만드는 `skills/<name>/SKILL.md` 레이아웃이 그대로 범용 레이아웃**이라, 대부분의 에이전트는 추가 파일이 0개다.

2단계(프로바이더 선택·린트)와 3단계(스캐폴딩)에서만 조회한다.

---

## 코어 4 — 설치 경로

| Agent | 프로젝트 경로 | 전역 경로 | 추가 파일 |
|---|---|---|---|
| Claude Code | `.claude/skills/` | `~/.claude/skills/` | 플러그인 배포 시 `.claude-plugin/plugin.json` + `marketplace.json` |
| Cursor 2.4+ | `.cursor/skills/`, `.agents/skills/` | — (프로젝트 전용) | **없음** |
| Codex CLI | `.agents/skills/` | `~/.agents/skills/` | `agents/openai.yaml` (**선택**) |
| Gemini CLI | `.gemini/skills/`, `.agents/skills/` | `~/.gemini/skills/`, `~/.agents/skills/` | **없음** |

Cline·Antigravity·Windsurf·Copilot 등 롱테일은 개별 문서화하지 않는다 — 아래 `npx skills add`가 커버한다.

---

## 설치 명령

**범용 (77개 에이전트)** — 어떤 조합을 골랐든 README에 항상 넣는다:

```bash
npx skills add <owner>/<repo>
```

주요 플래그: `-a/--agent <name>` 특정 에이전트만, `-s/--skill <name>|'*'` 특정 스킬만, `-g/--global` 홈 디렉토리에 설치, `-l/--list` 설치 없이 목록만, `--copy` 심볼릭 링크 대신 복사, `-y` 확인 생략.

`--list`는 배포 검증용으로도 쓴다 — 스킬이 목록에 뜨면 레이아웃이 올바르다는 뜻이다.

**Claude Code 플러그인** — Claude Code를 선택했을 때만:

```
/plugin marketplace add <owner>/<repo>
/plugin install <plugin-name>@<marketplace-name>
```

**수동 복사** — `skills/<skill-name>/` 을 위 표의 경로에 그대로 넣으면 된다.

---

## frontmatter 지원 매트릭스

린트(1단계 점검 → 2단계 보고)가 조회하는 표.

| 필드 | Claude Code | Cursor | Codex CLI | Gemini CLI |
|---|---|---|---|---|
| `name` (kebab-case, ≤64) | 필수 | 필수 | 필수 | 필수 |
| `description` (≤1024) | 필수 | 필수 | 필수 | 필수 |
| `allowed-tools` | 지원 | 무시 | 지원 | 무시 |
| `context: fork` | 지원 | 무시 | 무시 | 무시 |
| `model` | 지원 | 무시 | 무시 | 무시 |
| `paths` (glob 스코프) | 무시 | 지원 | 무시 | 무시 |
| `license`, `metadata` | 관용 | 관용 | 관용 | 관용 |
| 그 외 임의 필드 | 조용히 무시 | 조용히 무시 | 조용히 무시 | 조용히 무시 |

**핵심: 미지원 필드는 에러가 아니라 조용한 무시다.** 그래서 기본 권고는 "그대로 둔다". 제거를 권할 유일한 경우는 Claude Code를 선택하지 않았는데 Claude 전용 필드가 남아 있을 때 — 순수 사표(死票)다.

`allowed-tools`를 보안 경계로 쓰지 말 것. Claude Code와 Codex만 해석한다.

---

## 파일명 함정

파일명은 **정확히 `SKILL.md`**. `skill.md` / `Skill.md` 는 대소문자 구분 파일시스템에서 Gemini CLI·Antigravity가 **경고 없이 건너뛴다.** 소스가 다르면 복사본에서 고친다.

---

## Codex `agents/openai.yaml`

경로: `skills/<skill-name>/agents/openai.yaml` — **복사본에만.** 소스 스킬에는 만들지 않는다.

**선택 파일이다.** 없어도 Codex는 스킬을 정상적으로 읽는다. 기본은 생략하고, 사용자가 Codex UI 메타데이터를 원할 때만 만든다.

최소 형태 — 두 줄이면 충분:

```yaml
interface:
  display_name: "<Title Case Name>"
  short_description: "<한 줄, ~60자>"
```

나머지 스키마는 필요할 때만:

```yaml
# interface:
#   icon_small: "./assets/small-logo.svg"   # 에셋 파일이 실제로 있어야 함
#   icon_large: "./assets/large-logo.png"
#   brand_color: "#3B82F6"
#   default_prompt: "감싸는 프롬프트 문구"
# policy:
#   allow_implicit_invocation: true         # 기본값이 이미 true
# dependencies:
#   tools:                                  # 스킬이 실제로 MCP 서버를 요구할 때만
#     - type: "mcp"
#       value: "serverIdentifier"
#       description: "..."
#       transport: "streamable_http"
#       url: "https://example.com/mcp"
```

`icon_*`는 존재하지 않는 에셋을 가리키면 안 되므로, 아이콘 파일이 없으면 쓰지 않는다.
