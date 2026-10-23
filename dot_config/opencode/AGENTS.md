# Universal Agent Guidance

Guidance is Python-focused but generally applicable.

## External Outreach

- For requested MRs, comments, and similar actions, use neutral, factual language and end with:
  `Agent-generated. Prompt summary: <1-2 sentence summary>`
- Never perform external mutations unless clearly required by the user.

## Working files

- Put all working files in the project, under the working directory. This includes ephemeral ones: scratch
  scripts, notes, caches, virtualenvs and data dumps. Use an untracked (git-dirty) folder in the worktree, or the
  project folder above the worktrees (see Repository layout). Don't commit these files unless asked.
- Use `/tmp/opencode` only when there is no obvious project directory, and only for small files. `/tmp` is a
  16 GB in-memory filesystem shared by all agents, and the snap-installed `glab` can't read files there.

## Repository layout

Most checkouts use the `wt` worktree-catalogue layout (the fish function `wt`, in
`~/.config/fish/functions/wt.fish`):

```text
~/top/path/project-name/  # project folder; not itself a git checkout
├── .bare/                # the bare repository
├── project-name/         # main-branch worktree, named after the project
└── <branch>/             # one worktree per other branch
```

- A `.bare` folder in a parent directory identifies this layout. Run git commands inside a worktree, not in the
  project folder.
- Manage worktrees with `wt`, run through fish from inside the project folder:
  `fish -c 'cd <project folder>; wt new <branch> [base]'`. `wt co <branch>` checks out an existing branch and
  `wt status` lists all worktrees.
- Put notes shared across worktrees in the project folder, for example review indexes and MR drafts.
- Confirm the worktree and package root before reading guessed paths, especially in delegated tasks.

## Python

- Use `uv` for project commands unless project instructions say otherwise.
- Prefer `object` over `Any`; narrow with `assert`, `isinstance`, or reusable `TypeGuard`.
- Prefer immutability where practical. Follow established patterns in existing code.
- Prefer clear fluent API usage over long wrapper functions.
- Inline single-use literals instead of defining unnecessary constants.
- Use `cast()` only when the runtime type is genuinely known to be narrower. For incorrect library stubs, prefer a targeted `# type: ignore`.
- A git tag of an internal package isn't a release. Before locking a new version, confirm it is on the package index.

## Pydantic

- Prefer `Annotated[T, Field(...)]`; assign defaults normally.
- Put field descriptions in docstrings, except when `Field(description=...)` is needed for generated API documentation.
- Avoid implicitly coupled fields. Prefer explicit tagged/discriminated unions.

## FastAPI

- Prefer response return annotations over `response_model`.
- Put `Query()`, `Body()`, etc. in `Annotated`, with defaults assigned normally.
- Require timezone-aware public API inputs and convert them to UTC immediately.
- For external APIs, treat naive timestamps as UTC unless documented otherwise, then attach timezone information promptly.

## Time zones

- Use canonical IANA region names such as `Europe/Copenhagen`, not legacy names such as `CET`, `EET` or `MET`.
  The legacy names are now backward-compatibility links in tzdb, and some container images leave them out
  (Debian and Ubuntu ship them in a separate `tzdata-legacy` package).
- Don't rely on the host's timezone database. For Python code that uses `zoneinfo`, declare the `tzdata` package
  and verify with `PYTHONTZPATH` set to an empty directory, which simulates an image without system tzdata. If
  existing code uses a legacy name, check that the deployed image resolves it.

## Type Errors

- Avoid runtime changes solely to satisfy type checking unless needed for narrowing or exhaustiveness.
- Prefer correct annotations.
- Add maintained stub packages when library typing is missing or poor.
- Use targeted ignores only as a last resort.
- Do not choose an inferior runtime representation merely because it is easier to type.

## Tests

Apply these rules while writing tests, not only as a cleanup at the end. Before finishing, critically review any
tests you wrote or touched:

- Use minimal data and keep tests fast while still covering the intended invariants.
- Assert invariant behavior, not specific configuration values.
- Avoid combining parameterizations unless each combination covers something distinct.
- Prefer fewer, shorter tests with stronger assertions over many narrow ones.
- Cover specified behavior for realistic use cases; do not fuzz unless asked.
- A regression test must fail against the plausible broken implementation. For example, when testing ranking,
  keep the competing rows eligible.
- Before reporting a regression, confirm that the base revision behaves differently on the same public path.
- Run the repository's CI test selection, such as the markers that exclude external tests. Don't run tests that
  reach live services unless asked.

## Shell

- Write defensive shell scripts that tolerate missing optional files and unexpected user configuration.
- Scripts intended for sourcing must not fail while defining functions or sourcing optional files.
- User-invoked commands must fail fast.
- The user's shell is fish, so give snippets for the user to paste in fish syntax.

## Live and production data

- Treat stated limits on requests, samples and data size as hard ceilings. If the results suggest a wider
  problem, report what the sample shows and ask before going further.
- Fetch large windows once, cache them in the project, and run comparisons offline.
- Pass the target environment explicitly, rather than relying on client defaults.

## Context and long-running work

- Locate code with grep or glob, then read only the relevant ranges. Don't dump whole large modules or unbounded
  output.
- Match the precision the user asked for, and stop once the evidence answers the question.
- In long multi-phase work, write a short checkpoint file at each phase boundary: decisions, branch, commit and
  MR state, and open items. Suggest a fresh session for a distinct follow-up.
- Before starting a job that will take more than a few minutes, state the expected duration. Prefer jobs that
  write their output progressively.
- Don't finish while required background work is still running. Collect its result first.

## Delegation

When delegating to subagents:

- Choose the model by role:
  - `openai/gpt-6-astra`: architecture and hard analysis.
  - `openai/gpt-6.1-sol`: implementation.
  - `openai/gpt-6-luna`: exploration, and summarizing large amounts of text.
  - `github-copilot/claude-opus-5.5`: critical review, and prose in general (MR descriptions, reports, docs,
    messages).
- Keep tasks small: one narrow, verifiable deliverable per subagent that returns quickly. The parent can then
  change direction between these small loops. Several short rounds are better than one long autonomous task.
- `explore` agents have no shell. Use `general` for anything that needs git, glab, uv or network access.
- Give every task its exact worktree and package root, deliverable, constraints and limits. The
  `delegated-work` skill has a brief template and the coordination conventions.
