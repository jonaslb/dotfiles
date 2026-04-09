# Universal Agent Guidance

Main guidance focuses on Python, but advice given may apply "in spirit" regardless of language.

## Python Project Hints

### General

- Assume usage of `uv` to run project commands like pytest, ruff, etc. Unless the project instructions indicate otherwise.
- Use all Python's modern typing features: `str | None` instead of `Optional[str]`, `list[T]` instead of `List[T]`, and `class X[T]` instead of `class X(Generic[T])`, etc. IF pyproject.py lists a modern enough Python, of course.
- Use `object` over `Any` if dynamic typing required. Use asserts or isinstance checks for type narrowing (or, if reusability is desired, a TypeGuard).
- Prefer immutability whenever possible and practical. Ideally only "builder"-style objects mutate themselves - eventually they "build" to a final type and then are immutable. Classes not written anew, or which have other special circumstances, may not follow this pattern. In that case follow existing practice or whichever is necessary.
- Hints for Pydantic and FastAPI below can oftentimes generalize in spirit for other libraries.
- Avoid creating simple functions with long names that "hide" fluent API usage inside (at least, if it is not _very_ long). The fluent API is usually easier to understand directly.
- Heresy: The "javaism" of defining everything as a constant before usage. Please prefer inline literals, at least when reusability of that particular variable is not an explicity goal.
- Intention in type hints: Do not use `cast(..)` to circumvent type checking, only use it if we "know" that a type is narrower than the checker otherwise infers. If the type checker is wrong because some library type annotations are wrong, a `# type: ignore` is more appropriate.

### Pydantic

- Use `var: Annotated[T, Field(...)]` over `var: T = Field(...)`. Then use classical ` = default_value` for defaults.
- Put any field description in a docstring immediately below the field instead of inside `Field(..)`.
- Avoid implicitly coupled fields; favor explicit tagged unions for configuration (e.g., auth modes) instead of enums + optional fields.
    For example:
    ```python
    # BAD:
    class Arguments(BaseModel):
        filter_mode: Literal["explicit", "time_cutoff"]
        explicit_filter: str | None = None  # Required if mode=explicit
        cutoff_time: datetime | None = None  # required if mode=time_cutoff
    # GOOD:
    class TimeFilter(BaseModel):
        mode: Literal["time_cutoff"] = "time_cutoff"
        cutoff_time: datetime
    class ExplicitFilter(BaseModel):
        mode: Literal["explicit"] = "explicit"
        value: str
    class Arguments(BaseModel):
        filter: Annotated[
             TimeFilter | ExplicitFilter,
             Field(discriminator="mode")  # Optional if types are very distinct or dont have tag
        ]
    ```

### FastAPI

- Prefer relying on return type annotations for responses; avoid explicit `response_model=...` unless necessary.
- Use `status: Annotated[list[RunStatus] | None, Query()] = None` rather than `status: list[RunStatus] | None = Query(default=None)`. This goes for other annotations like `Body()` as well.
- Always require timezone information for inputs in public APIs. Raise an error explicitly instead of relying on `tz_convert` failing. Convert the provided datetimes to UTC ASAP.
- External (to the project) APIs may use timezone-naive objects. Convert these to UTC and ensure they carry timezone information ASAP. To this end, you may assume that naive timestamps are UTC, unless explicitly known/documented otherwise for a given API.

### Type check Failures (mypy, pyrefly, ty, ..)

Try to avoid making runtime changes to fix type errors, unless it is something like an exhaustiveness/narrowing check that only requires a branch.
Try to annotate correct types instead.
If the cause is missing or poor type hints in a library, it may be that we should add a "stubs" or "types" library to dev dependencies. This is done like `uv add --dev pandas-stubs`, for example.
As a final fallback, a type ignore comment might be necessary, but should be used sparingly.
In the end, type information should be used to "reinforce" the stability of code correctness in the face of future (possibly not fully informed) changes, and that is only possible with as few as possible "type overrides".
We should also not use inferior solutions like converting an array to a list just because the typing is easier.

## Shell (bash, fish, etc)

Shell scripts should be highly defensive against unexpected user configurations - directories or files not existing, etc.
Scripts intended for environment inclusion must not error when executed to define functions, source other files, etc.
When a user command is run, it must "fail fast".

## Git

A fish utility `wt` is present for working with git worktrees.
Specifically, `wt new <branch>` creates `base/project/<branch>` on a new branch off main.
Also available is `wt co` (checkout existing branch as with new), `wt convert` (normal git repo to worktree layout), `wt update`, and `wt help`.

