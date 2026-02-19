# Python Project Hints

## General

- Assume usage of `uv` to run project commands like pytest, ruff, etc. Unless the project instructions indicate otherwise.
- Use all Python's modern typing features: `str | None` instead of `Optional[str]`, `list[T]` instead of `List[T]`, and `class X[T]` instead of `class X(Generic[T])`, etc. IF pyproject.py lists a modern enough Python, of course.
- Use `object` over `Any` if dynamic typing required. Use asserts or isinstance checks for type narrowing (or, if reusability is desired, a TypeGuard).
- Hints for Pydantic and FastAPI below can oftentimes generalize in spirit for other libraries.

## Pydantic

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

## FastAPI

- Prefer relying on return type annotations for responses; avoid explicit `response_model=...` unless necessary.
- Use `status: Annotated[list[RunStatus] | None, Query()] = None` rather than `status: list[RunStatus] | None = Query(default=None)`. This goes for other annotations like `Body()` as well.
- Always require timezone information for inputs in public APIs. Raise an error explicitly instead of relying on `tz_convert` failing. Convert the provided datetimes to UTC ASAP.
- External (to the project) APIs may use timezone-naive objects. Convert these to UTC and ensure they carry timezone information ASAP. To this end, you may assume that naive timestamps are UTC, unless explicitly known/documented otherwise for a given API.

