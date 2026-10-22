# Preserve Task Goals

[中文说明](README.md) · [Installation guide](docs/installation.md) · [Skill instructions](SKILL.md)

An instruction-based Agent Skill for Codex that helps keep the agreed goal, actual implementation, validation evidence, and completion claims aligned.

It addresses scope shrinkage, unauthorized method substitution, fixation on local details, ineffective placeholder implementations, circular validation, weakened acceptance criteria, stale evidence, and premature completion claims.

## Install with Codex

Paste this into a Codex conversation:

```text
Use $skill-installer to install https://github.com/Huihuiwei/preserve-task-goals.
SKILL.md is at the repository root: use path . and the installation name preserve-task-goals.
Inspect the skill first, use the personal skill location supported by this Codex installation,
and preserve any existing local modifications. Report the actual installation location.
```

Then invoke:

```text
Use $preserve-task-goals to continue this task within the agreed scope.
Check the real implementation and evidence, then complete the remaining required work.
```

## Manual installation

For Codex installations using the documented user-level `.agents/skills` directory:

macOS / Linux:

```bash
mkdir -p "$HOME/.agents/skills"
git clone https://github.com/Huihuiwei/preserve-task-goals.git "$HOME/.agents/skills/preserve-task-goals"
```

Windows PowerShell:

```powershell
$skillParent = Join-Path $env:USERPROFILE '.agents\skills'
New-Item -ItemType Directory -Path $skillParent -Force | Out-Null
git clone https://github.com/Huihuiwei/preserve-task-goals.git (Join-Path $skillParent 'preserve-task-goals')
```

If the destination already exists, inspect it instead of overwriting it. Some bundled installers use `$CODEX_HOME/skills` or `~/.codex/skills`; use the location supported by your installation and avoid duplicate copies. If discovery does not refresh, start a new session or restart Codex.

For project-only use, place the repository in `.agents/skills/preserve-task-goals` under that project. See the [detailed guide](docs/installation.md) for ZIP installation, updates, removal, and troubleshooting.

Windows users with a local checkout can run `& .\scripts\install-local.ps1 -AddGlobalInstructions` from the repository directory. This offline installer follows the bundled installer's `$CODEX_HOME/skills` convention, defaulting to `%USERPROFILE%\.codex\skills`. The optional switch backs up and appends to global `AGENTS.md`; existing differing skill files are not overwritten. Installation applies to the current Windows user's projects, and a new Codex session must still confirm discovery. It does not change execution policies or sandbox permissions.

## Capabilities

- Reconstruct agreed requirements without turning assistant suggestions into user approval.
- Separate implementation fixes from changes to scope, methods, or acceptance criteria.
- Keep local subtasks tied to required deliverables.
- Check that mechanisms actually participate in execution.
- Use discriminating validation and trace results to their versions and conditions.
- Report negative results, blockers, and missing evidence accurately.
- Recover from task drift without discarding useful work.
- Use lightweight records only when complexity warrants them.
- Check task identity separately from completeness: passing checks for a substitute task does not satisfy the agreed task.
- Continue authorized, executable required work without waiting for repeated requests to continue; pause only with a concrete blocker or an explicit user instruction.
- Recheck the original agreed goal plus explicitly approved changes at each turn, before adding a branch, and before delivery; do not rely only on the previous assistant plan.
- Require new work to address a required deliverable, actual blocker, or directly relevant validation risk. A potentially useful addition is not automatically authorized.
- Separate goal alignment, requirement coverage, real behavior, and evidence. Trace critical functions from the actual entry point to the delivered output.
- Respect read-only and pause instructions; on resumption, check current conditions and retain requirements unaffected by an approved change.

These are lightweight execution checks, not a requirement to create a report or rerun the entire test suite every turn. Conditional guidance is in [alignment and completion](references/alignment-and-completion.md).

Keep standing project rules in `AGENTS.md`; use the skill for the workflow. An optional [AGENTS.md snippet](templates/AGENTS-snippet.md) is included. Default installation only places files; explicitly passing `-AddGlobalInstructions` to the local installer backs up and appends global guidance without rewriting project rules.

## Limits

This is a procedural aid, not an enforcement engine or a guarantee of correctness. There are no task runtime scripts, background processes, or telemetry; installation and evaluation helpers run only when requested. The core instructions are in Chinese and direct the agent to respond in the user's language. Other SKILL.md-compatible hosts may use the content, but their discovery and invocation behavior must be verified separately.

## Evaluate actual behavior

[Optional maintainer evaluations](evals/README.md) cover complete delivery, partial blockers, pause/resume with an approved change, and real parameter effects through the execution path. Their Python checkers use only the standard library and are not runtime dependencies. They check outputs and preserved inputs; a maintainer must also review actual actions, claims, and scope choices. See [recorded runs](evals/RESULTS.md) for version-specific evidence. Passing these cases does not establish broad reliability or a measured improvement over a no-skill baseline.

## License

[MIT](LICENSE).
