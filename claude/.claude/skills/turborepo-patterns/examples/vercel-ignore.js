// Example vercel-ignore-app-changes.mjs — robust ignoreCommand for a Vercel app
// in a monorepo. Wired up from each app's vercel.json:
//
//   {
//     "ignoreCommand": "node ../../scripts/vercel-ignore-app-changes.mjs"
//   }
//
// Exit 0 = skip build (nothing changed); exit 1 = proceed with build.
//
// Falls back through three diff bases (in priority order):
//   1. VERCEL_GIT_PREVIOUS_SHA  — last successful deploy SHA (most accurate)
//   2. git merge-base origin/main — handles multi-commit pushes correctly
//   3. HEAD~1                   — last-resort single-commit comparison
//
// Referenced from: ~/.claude/skills/turborepo-patterns/SKILL.md
//
// pseudo-code:
const previousSha = process.env.VERCEL_GIT_PREVIOUS_SHA;
const baseSha = previousSha || (await gitMergeBase('origin/main')) || 'HEAD~1';
const changed = await gitDiff(baseSha, 'HEAD', appPath);
process.exit(changed ? 1 : 0);
