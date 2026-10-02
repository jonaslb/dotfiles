# Universal Agent Guidance

Guidance is Python-focused but generally applicable.

## External Outreach

- For requested MRs, comments, and similar actions, use neutral, factual language and end with:
  `Agent-generated. Prompt summary: <1-2 sentence summary>`
- Never perform external mutations unless clearly required by the user.

## Python

- Use `uv` for project commands unless project instructions say otherwise.
- Prefer `object` over `Any`; narrow with `assert`, `isinstance`, or reusable `TypeGuard`.
- Prefer immutability where practical. Follow established patterns in existing code.
- Prefer clear fluent API usage over long wrapper functions.
- Inline single-use literals instead of defining unnecessary constants.
- Use `cast()` only when the runtime type is genuinely known to be narrower. For incorrect library stubs, prefer a targeted `# type: ignore`.

## Pydantic

- Prefer `Annotated[T, Field(...)]`; assign defaults normally.
- Put field descriptions in docstrings, except when `Field(description=...)` is needed for generated API documentation.
- Avoid implicitly coupled fields. Prefer explicit tagged/discriminated unions.

## FastAPI

- Prefer response return annotations over `response_model`.
- Put `Query()`, `Body()`, etc. in `Annotated`, with defaults assigned normally.
- Require timezone-aware public API inputs and convert them to UTC immediately.
- For external APIs, treat naive timestamps as UTC unless documented otherwise, then attach timezone information promptly.

## Type Errors

- Avoid runtime changes solely to satisfy type checking unless needed for narrowing or exhaustiveness.
- Prefer correct annotations.
- Add maintained stub packages when library typing is missing or poor.
- Use targeted ignores only as a last resort.
- Do not choose an inferior runtime representation merely because it is easier to type.

## Shell

- Write defensive shell scripts that tolerate missing optional files and unexpected user configuration.
- Scripts intended for sourcing must not fail while defining functions or sourcing optional files.
- User-invoked commands must fail fast.
