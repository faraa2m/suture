# Local LLM Orchestrator

Local LLM Orchestrator is a zero-dependency `.ai/` control plane for autonomous coding agents. It is designed to be copied into any repository and used with Claude Code, Codex, Gemini CLI, Cursor, Windsurf, or any other local agent runner that can read Markdown instructions and execute shell hooks.

The project treats the filesystem as the API. Prompts, state, routing policy, task memory, and tool-specific adapters are all plain files. There is no daemon, database, SDK, or vendor lock-in.

## The Problem

Modern agentic coding workflows often hand every task to the largest available adaptive-thinking model. That is wasteful.

Models with adaptive thinking modes, such as Anthropic's Fable 5, are valuable when a task requires routing, ambiguity reduction, or strategic judgment. They are expensive when asked to do menial work:

- Running predictable shell commands.
- Rewriting boilerplate.
- Applying mechanical edits.
- Re-reading stale context because the session is bloated.
- Explaining internal reasoning when only a tool call is needed.
- Looping on task state because memory lives in the chat transcript.

The result is a common failure mode: premium tokens are burned on low-value execution while the actual project state becomes harder to inspect, compress, and resume.

## The Solution

Local LLM Orchestrator separates routing, execution, and synthesis into explicit roles.

### Fable 5 as the Orchestrator

Fable 5 is used strictly as a zero-thought router. It reads the current filesystem state, chooses the next worker, and emits only the next tool call or handoff instruction. It does not narrate, deliberate in public, or generate bulk code unless the task is genuinely strategic.

### Haiku as the Swarm

Haiku handles menial tool execution and narrow implementation work:

- File reads and search.
- Formatting.
- Small code edits.
- Test runs.
- Boilerplate generation.
- Mechanical repository inspection.

The goal is to keep cheap, fast models busy on bounded tasks while preventing them from owning global project state.

### Sonnet as the Synthesizer

Sonnet updates state after worker execution. It compresses noisy output into durable Markdown facts:

- What changed.
- What was verified.
- What failed.
- What remains blocked.
- The exact next action.

Opus can be configured for high-risk architectural synthesis, but the default assumes Sonnet is the state synthesis tier.

### Filesystem as the API

The `.ai/` directory is the orchestration interface:

- `.ai/router.md` defines routing behavior.
- `.ai/memory.md` stores current state.
- `.ai/config.yaml` maps task classes to models and tools.
- `.ai/skills/` stores downloaded external prompt skills.
- `.ai/hooks/` stores shell entry points.
- `.ai/templates/` stores tool-specific instruction snippets.

Any agent CLI can participate by reading these files and writing back terse state updates.

## Repository Layout

```text
.
├── .ai/
│   ├── config.yaml
│   ├── memory.md
│   ├── router.md
│   ├── hooks/
│   │   └── pre-eval.sh
│   ├── skills/
│   │   └── README.md
│   └── templates/
│       ├── AGENTS.md
│       ├── CLAUDE.md
│       ├── GEMINI.md
│       ├── cursor-rules.md
│       └── windsurf-rules.md
├── bin/
│   └── ai-scaffold
├── LICENSE
└── README.md
```

## Installation

Copy `.ai/` into an existing repository:

```sh
cp -R /path/to/local-llm-orchestrator/.ai /path/to/your-repo/.ai
```

Or use the scaffold helper from this repository:

```sh
./bin/ai-scaffold --target /path/to/your-repo --tool defaults
```

The scaffold helper has no dependencies beyond POSIX shell utilities.

## Scaffold Options

Install the defaults for the common local coding tools and download the latest external skills:

```sh
./bin/ai-scaffold --target /path/to/your-repo --tool defaults --skills latest
```

Install a specific adapter:

```sh
./bin/ai-scaffold --target /path/to/your-repo --tool claude
./bin/ai-scaffold --target /path/to/your-repo --tool codex
./bin/ai-scaffold --target /path/to/your-repo --tool gemini
./bin/ai-scaffold --target /path/to/your-repo --tool cursor
./bin/ai-scaffold --target /path/to/your-repo --tool windsurf
```

Ask interactively:

```sh
./bin/ai-scaffold --target /path/to/your-repo --tool ask
```

Skip external skills when you only want the base `.ai/` control plane:

```sh
./bin/ai-scaffold --target /path/to/your-repo --tool defaults --skills skip
```

Tool adapters are intentionally small. They point the local agent at `.ai/router.md`, `.ai/memory.md`, `.ai/config.yaml`, and externally downloaded prompt hygiene skills instead of duplicating policy across tools.

## External Skill Sources

`caveman` and `ponytail` are treated as externally owned skills. The scaffold downloads their latest Markdown at install time instead of shipping hand-written copies in this repository.

Both upstream repositories already use a strong cross-harness structure: agent instructions, skill manifests, command hooks, and adapters for common coding environments live close to the skill source. Local LLM Orchestrator leans on that structure instead of reimplementing it. The `.ai/` control plane mounts the latest skill Markdown and lets Claude Code, Codex, Gemini, Cursor, Windsurf, and similar harnesses consume the same policy through their native instruction files.

Default sources:

- Caveman: `https://github.com/JuliusBrussee/caveman`
- Ponytail: `https://github.com/DietrichGebert/ponytail`

The installer fetches:

- `https://raw.githubusercontent.com/JuliusBrussee/caveman/main/skills/caveman/SKILL.md`
- `https://raw.githubusercontent.com/DietrichGebert/ponytail/main/skills/ponytail/SKILL.md`

Override with flags:

```sh
./bin/ai-scaffold --target /path/to/your-repo --skills latest \
  --caveman-url https://example.com/caveman.md \
  --ponytail-url https://example.com/ponytail.md
```

Or environment variables:

```sh
CAVEMAN_SKILL_URL=https://example.com/caveman.md \
PONYTAIL_SKILL_URL=https://example.com/ponytail.md \
./bin/ai-scaffold --target /path/to/your-repo --skills latest
```

For offline development, `file://` URLs are supported:

```sh
./bin/ai-scaffold --target /path/to/your-repo --skills latest \
  --caveman-url file:///absolute/path/to/caveman.md \
  --ponytail-url file:///absolute/path/to/ponytail.md
```

## Model Configuration

Edit `.ai/config.yaml` to change model routing by task class:

```yaml
models:
  router:
    provider: anthropic
    model: fable-5
    role: zero-thought routing only
  worker:
    provider: anthropic
    model: haiku
    role: bounded tool execution and mechanical edits
  synthesizer:
    provider: anthropic
    model: sonnet
    role: state compression and next-action synthesis
  architect:
    provider: anthropic
    model: opus
    role: optional high-risk architecture review
```

Routes are task based, not tool based. You can map `search`, `edit`, `test`, `summarize`, `review`, or `architecture` to different models without changing the hook entry points.

## Hook Usage

Run the pre-evaluation loop from the target repository:

```sh
.ai/hooks/pre-eval.sh
```

The hook reads `.ai/memory.md` and `.ai/config.yaml`, then prints the routing payload that should be passed to the local orchestrator. By default it simulates the loop so the repository stays dependency-free.

Integrate it with a local agent CLI by replacing the marked section in `.ai/hooks/pre-eval.sh` with your tool invocation:

```sh
claude --system-prompt "$(cat .ai/router.md)" --input "$(cat .ai/memory.md)"
codex exec --config .ai/config.yaml "$(cat .ai/router.md)"
gemini --prompt "$(cat .ai/router.md)"
```

Exact flags vary by tool. The contract is stable: read Markdown state, route one step, execute bounded work, and write a compressed update back to `.ai/memory.md`.

## Tests

Run the scaffold tests with:

```sh
./tests/test-ai-scaffold.sh
```

The tests use temporary directories and `file://` skill sources, so they do not require network access.

## Operating Loop

1. Router reads `.ai/memory.md`.
2. Router emits one tool call or one worker handoff.
3. Worker performs a bounded task.
4. Synthesizer compresses results into `.ai/memory.md`.
5. Hook repeats until `current_phase` is `complete` or `blocked_by` is non-empty.

## Design Principles

- Zero dependencies by default.
- Markdown over hidden state.
- Small models for small work.
- Larger models only for synthesis, ambiguity, and risk.
- No long-lived chat transcript as source of truth.
- Every loop must leave the repository easier to resume.

## License

MIT. See [LICENSE](LICENSE).
