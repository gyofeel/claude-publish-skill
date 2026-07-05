# README 골격

public 플러그인 repo의 README는 아래 순서를 따른다. `<...>`를 채운다.

```markdown
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

In Claude Code:

```
/plugin marketplace add <owner>/<repo>
/plugin install <plugin-name>@<marketplace-name>
```

## What's inside

```
skills/<plugin-name>/
├── SKILL.md
├── scripts/            # (있으면)
└── references/
```

## License

MIT — see [LICENSE](LICENSE).
```

## 작성 팁

- 제목 아래 첫 문장으로 "무엇을 하는지"를 즉시 전달.
- Install 블록의 두 이름 대응을 정확히: `<plugin-name>@<marketplace-name>`.
- 스킬 SKILL.md가 특정 언어(예: 한국어)면 "language-agnostic" 한 줄로 사용자 안심.
