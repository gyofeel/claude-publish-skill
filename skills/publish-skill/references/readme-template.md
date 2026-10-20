# README 골격

배포 repo의 README는 아래 순서를 따른다. `<...>`를 채운다.

````markdown
# <plugin-name>

<한 문장: 이 스킬이 하는 일.>

<한 문단: 왜 이게 유용한가 — 어떤 반복/고통을 없애는가.>

## Why

- **<핵심 가치 1>** — 설명.
- **<핵심 가치 2>** — 설명.
- **<핵심 가치 3>** — 설명.

## <파이프라인 / 기능>

<번호 단계 또는 불릿으로 스킬의 흐름·기능 요약.>

## Install

<!-- private일 때만 -->
> This is a private repository — installing requires read access to it (your existing `gh` login or SSH key is used).

Works in any agent that reads `SKILL.md` — Claude Code, Cursor, Codex CLI, Gemini CLI, and 70+ more:

```bash
npx skills add <owner>/<repo>
```

<!-- Claude Code를 선택했을 때만 -->
Or install as a Claude Code plugin (marketplace updates included):

```
/plugin marketplace add <owner>/<repo>
/plugin install <plugin-name>@<marketplace-name>
```

<details>
<summary>Manual install</summary>

Copy `skills/<skill-name>/` into your agent's skills directory:

| Agent | Project | Global |
|---|---|---|
| Claude Code | `.claude/skills/` | `~/.claude/skills/` |
| Cursor | `.cursor/skills/` | — (project only) |
| Codex CLI | `.agents/skills/` | `~/.agents/skills/` |
| Gemini CLI | `.gemini/skills/` | `~/.gemini/skills/` |

</details>

## What's inside

```
skills/<plugin-name>/
├── SKILL.md
├── scripts/            # (있으면)
└── references/
```

<!-- public일 때만. private는 License 섹션 자체를 뺀다 -->
## License

MIT — see [LICENSE](LICENSE).
````

## 작성 팁

- 제목 아래 첫 문장으로 "무엇을 하는지"를 즉시 전달.
- Install 블록의 두 이름 대응을 정확히: `<plugin-name>@<marketplace-name>`.
- 스킬 SKILL.md가 특정 언어(예: 한국어)면 "language-agnostic" 한 줄로 사용자 안심.
- **Install 섹션은 선택한 에이전트만 남긴다.** Claude Code를 안 골랐으면 `/plugin` 블록도 지우고, Manual install 표에서도 그 행을 지운다. 검증 안 한 걸 문서화하지 않는다.
- `npx skills add` 줄은 어떤 조합에서도 유지 — 레이아웃이 곧 표준이라 항상 유효하다.
- private면 Install 맨 위에 접근 권한 안내 한 줄을 넣고, License 섹션은 뺀다(LICENSE 파일도 없음).
- `<!-- ... -->` 주석은 템플릿 안내용이다. 실제 README에는 남기지 않는다.
