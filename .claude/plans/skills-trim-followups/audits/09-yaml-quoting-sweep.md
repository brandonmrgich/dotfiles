# Task 09 audit — YAML quoting sweep

Closes parent plan `skills-trim-and-discipline` Phase-8 follow-up #8.

## Method

For each discoverable skill directory, walked every `SKILL.md` and ran
`python3 -c "import yaml; yaml.safe_load(<frontmatter>)"`. Files whose
frontmatter failed to parse AND whose `description:` value contained an
unquoted colon were rewritten with the description value wrapped in
double quotes.

## Directories scanned

| Directory | SKILL.md count | Notes |
|---|---|---|
| `~/dotfiles/claude/.claude/skills` (source for `~/.claude/skills`) | 28 | All clean — parent plan Task 17 already swept |
| `~/Development/GithubTools/claude-collab/agent_collab/plan-executor/skills` | 2 | All clean |
| `~/Development/GitHubProjects/MusicPortfolio/.claude/skills` | 7 | 5 needed fix, 2 clean |
| `~/Development/GithubTools/claw-code/src/skills` | 0 | Scanned — no SKILL.md present (only `__init__.py`) |

Total SKILL.md files inspected: **37**.

## Files needing fix

Five files in MusicPortfolio. All shared the same defect: the
`description:` value contained an unquoted colon (e.g. `any of:`,
`KYC),`), which YAML interprets as a nested mapping and rejects.

| File | First failing column | Trigger phrase |
|---|---|---|
| `MusicPortfolio/.claude/skills/music-platform-data-standards/SKILL.md` | col 652 | `reference any of:` |
| `MusicPortfolio/.claude/skills/music-platform-state-machines/SKILL.md` | col 858 | `reference any of:` |
| `MusicPortfolio/.claude/skills/music-platform-media/SKILL.md` | col 938 | `mentions any of:` |
| `MusicPortfolio/.claude/skills/music-platform-api/SKILL.md` | col 474 | `reference any of:` |
| `MusicPortfolio/.claude/skills/music-platform-admin-forms/SKILL.md` | col 1041 | `mentions any of:` |

## Fix applied

For each file, the `description:` value was wrapped in double quotes
(no other content changes, no escaping required — verified no embedded
`"` characters in any of the five description bodies). Re-ran
`yaml.safe_load` over all 37 files post-fix: zero failures.

## Files already clean (32)

- `~/dotfiles/claude/.claude/skills/`: astro-static-sites,
  ddex-standards, design-before-code, doc-freshness, environment-map,
  essay, finishing-a-branch, github, gitignore, idea-tracker,
  nextjs-app-router, plan-auditor, plan-executor, receiving-code-review,
  requesting-code-review, royalty-splits-music, session-ready,
  skill-author, systematic-debugging, test-driven-development,
  top-down-sweep, turborepo-patterns, using-homebrew-skills,
  verification-before-completion, web-audio-howler,
  worktree-orchestrator, zoom-in, zoom-out (28).
- `claude-collab/agent_collab/plan-executor/skills/`: plan-auditor,
  plan-executor (2).
- `MusicPortfolio/.claude/skills/`: music-platform-architecture,
  music-platform-stream-player-ux (2).

## Cross-repo split

Fixes were committed in the MusicPortfolio repo (separate git repo).
This audit report is committed in the dotfiles repo as the plan's
artifact of record. Both commits carry `Plan: skills-trim-followups`
and `Task: 09` footers.

## Outcome

- 5 files fixed, 32 files clean, 0 files unresolved.
- Phase-8 follow-up #8 closed.
