---
name: create-pull-request
description: Create a new Pull Request from the current branch with a full description. Invoke for every new PR in this repository — whether the user asks for one ("create a PR", "PRを作って") or Claude is about to open one on its own after finishing work.
argument-hint: [issue-url]
allowed-tools:
  - Bash(gh pr create:*)
  - Bash(gh pr list:*)
  - Bash(gh pr view:*)
  - Bash(gh issue view:*)
  - Bash(git log:*)
  - Bash(git diff:*)
  - Bash(git status)
  - Bash(git push:*)
---

# Create a Pull Request (DatePlus)

Create the PR in a single `gh pr create` call with the title and body ready —
never create an empty PR and fill it in afterwards.

## Title

| Format | Examples |
|--------|----------|
| `<type>: <description>` | `fix: restore widget display and complete refactor cleanup`, `docs: update README.md` |

- English, lowercase `<type>` from the repository vocabulary: `feat` / `fix` /
  `refactor` / `chore` / `docs` / `test` / `perf` / `ci` / `style` / `build` /
  `release`
- No ticket or issue prefix in the title. Reference related issues in the body
  with `Closes #N` (auto-close) or `Refs #N`
- Usually the title matches the branch's primary commit subject

## Base branch

- `--base develop` for all feature/fix/docs work
- Release PRs only: `develop` → `release` (`release: vX.Y.Z`) and
  `release` → `main`

## Body structure

Write the body in English from `git log <base>..HEAD` and
`git diff <base>...HEAD` (and the linked issue, if any):

```markdown
## Background
Why the change exists: the problem, its root cause if known, and links
(Closes #N / Refs #N).

## What this PR delivers
User- or contributor-visible outcomes, one bullet per point. For multi-commit
branches, add a short numbered commit summary.

## Validation
- [x] Checks actually performed, with concrete commands and results
- [ ] Checks that remain open (state explicitly where they will happen,
      e.g. TestFlight)

## Notes (optional)
Force pushes, compatibility guarantees, follow-ups, reviewer guidance.
```

Only check a Validation box for something that was actually run and observed.

## Procedure

1. If an issue URL was passed as an argument, read it with `gh issue view`
2. Confirm the branch is pushed (`git push -u origin <branch>` if needed)
3. Compose the title and body per the rules above
4. `gh pr create --base develop --title "<title>" --body "<body>"` (or
   `--body-file` for long bodies)
5. Report the PR URL to the user

## Language policy

PR titles and bodies are English. The result reported to the user in the
shell follows the user's language.

## Red flags — stop and check first

- Title in Japanese or with a `[TICKET]` prefix → this repository uses English
  `<type>: <description>` titles; link issues in the body instead
- About to target `main` with feature work → the PR base is `develop`
- A Validation checkbox is checked for a step that was not actually run →
  uncheck it and state it as pending
