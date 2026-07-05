# Contributing

Suture is intentionally small. Contributions should preserve the core contract: filesystem state, Markdown instructions, shell hooks, and zero runtime dependencies.

## Development

Run the scaffold tests:

```sh
./tests/test-ai-scaffold.sh
```

Run a live skill-source smoke test when changing default skill URLs:

```sh
tmpdir=$(mktemp -d /tmp/suture-live.XXXXXX)
./bin/ai-scaffold --target "$tmpdir" --tool codex --skills latest
test -s "$tmpdir/.ai/skills/caveman.md"
test -s "$tmpdir/.ai/skills/ponytail.md"
rm -rf "$tmpdir"
```

## Pull Requests

- Keep changes focused.
- Add or update shell-level tests for scaffold behavior.
- Update `README.md` when user-facing behavior changes.
- Do not add package managers, daemons, databases, or runtime dependencies without prior discussion.
- Keep external skills externally sourced instead of vendoring prompt bodies.

## Design Constraints

- `.ai/memory.md` is durable state.
- `.ai/router.md` is routing policy.
- `.ai/config.yaml` maps model roles and adapters.
- `.ai/hooks/` contains boring shell entry points.
- `.ai/skills/` contains downloaded external skill files or source notes.
