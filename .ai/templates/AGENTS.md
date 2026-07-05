# Suture Adapter

This repository uses `.ai/` as the agent control plane.

## Required Reads

- `.ai/router.md`
- `.ai/memory.md`
- `.ai/config.yaml`
- `.ai/skills/caveman.md`, if installed
- `.ai/skills/ponytail.md`, if installed

## Rules

- Treat `.ai/memory.md` as source of truth.
- Keep context out of chat when it belongs in Markdown.
- Use the cheapest configured model role that can complete the task.
- Run `.ai/hooks/pre-eval.sh` before autonomous execution loops.
- Compress worker output into `.ai/memory.md` after each bounded task.
- If a referenced skill is missing, run `bin/ai-scaffold --skills latest` from the orchestrator source or continue with the base router rules.
