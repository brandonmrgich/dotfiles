# Changelog

All notable changes to this dotfiles repo. Newest first.

## [Unreleased] — expected next tag: `v2.0.0`

### Removed

- **`claude/` stow package** — the user-level Claude Code configuration
  (CLAUDE.md, statusline, skills, agents, commands, environment map,
  mantras, references, ideas, essays, tools) has been migrated to a
  dedicated repo:
  [`brandonmrgich/bam-claude`](https://github.com/brandonmrgich/bam-claude).
- **`.claude/plans/`** — plan-executor state directories
  (`skills-trim-and-discipline`, `skills-trim-followups`) were a
  byproduct of working on the Claude config inside this repo. They
  belong with the Claude config, not the dotfiles, and are removed
  from this repo.

### Changed

- `README.md` and `CLAUDE.md` slimmed to reflect the new scope:
  user/tooling configuration only (`git`, `starship`, `tmux`, `zsh`).
  Pointers to `bam-claude` added where relevant.

### Migration notes

The canonical migration record — with date, file mappings, and
user-run follow-up steps for git tags / GitHub releases — lives at
[`bam-claude/MIGRATION.md`](https://github.com/brandonmrgich/bam-claude/blob/main/MIGRATION.md).

TL;DR for this repo, after the migration PR merges:

```bash
cd ~/dotfiles
git checkout main
git pull --ff-only

# New version reflecting the slimmed scope.
git tag -a v2.0.0 -m "Dotfiles slim: claude config migrated to bam-claude repo"
git push origin v2.0.0

# Then create the GitHub release at
#   https://github.com/brandonmrgich/dotfiles/releases/new
# tag: v2.0.0, title: "v2.0.0 — Slim dotfiles (claude moved to bam-claude)"
```

If you previously stowed the old `claude` package, refresh local symlinks
per `bam-claude/README.md` § *Post-install: fix old stow links*.
