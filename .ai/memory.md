# Agent Memory

```yaml
current_phase: bootstrap
completed_steps: []
blocked_by: null
next_action: "Run .ai/hooks/pre-eval.sh to start the local orchestration loop."
active_tool: null
active_model_role: router
last_verified: null
open_questions: []
artifacts:
  state_source: ".ai/memory.md"
  router_prompt: ".ai/router.md"
  config: ".ai/config.yaml"
```

## Current Objective

Describe the user-visible outcome in one sentence.

## Router Notes

- Read the YAML state block first.
- Route one bounded action at a time.
- Prefer worker execution for search, mechanical edits, formatting, and tests.
- Prefer synthesizer execution for state compression, review, and next-action selection.

## Synthesizer Update Zone

The synthesizer overwrites this section after each worker task. Keep it terse.

```text
status: bootstrap
delta: no worker output recorded yet
evidence: none
risks: none recorded
next: run the pre-eval hook
```

## Worker Ledger

Append one line per worker result.

```text
YYYY-MM-DDTHH:MM:SSZ | role=worker | task=<task> | result=<pass|fail|blocked> | evidence=<path or command>
```
