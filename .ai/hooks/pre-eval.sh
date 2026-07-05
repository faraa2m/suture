#!/usr/bin/env sh
set -eu

# Local LLM Orchestrator pre-evaluation hook.
#
# This script is the dependency-free entry point for the orchestration loop.
# It reads Markdown state, builds a routing payload, and prints the next action
# that a local CLI tool should execute.
#
# Integration examples:
#   claude --system-prompt "$(cat .ai/router.md)" --input "$(cat .ai/memory.md)"
#   codex exec --config .ai/config.yaml "$(cat .ai/router.md)"
#   gemini --prompt "$(cat .ai/router.md)"
#
# Keep this hook boring. Tool-specific behavior belongs in adapters or wrapper
# scripts; durable project state belongs in .ai/memory.md.

ROOT_DIR=${1:-$(pwd)}
AI_DIR="$ROOT_DIR/.ai"
MEMORY_FILE="$AI_DIR/memory.md"
ROUTER_FILE="$AI_DIR/router.md"
CONFIG_FILE="$AI_DIR/config.yaml"

if [ ! -f "$MEMORY_FILE" ]; then
  echo "error: missing $MEMORY_FILE" >&2
  exit 1
fi

if [ ! -f "$ROUTER_FILE" ]; then
  echo "error: missing $ROUTER_FILE" >&2
  exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
  echo "error: missing $CONFIG_FILE" >&2
  exit 1
fi

echo "local-llm-orchestrator: pre-eval"
echo "root: $ROOT_DIR"
echo "router: $ROUTER_FILE"
echo "memory: $MEMORY_FILE"
echo "config: $CONFIG_FILE"
echo
echo "=== routing payload ==="
echo "--- router.md ---"
sed -n '1,220p' "$ROUTER_FILE"
echo
echo "--- memory.md ---"
sed -n '1,220p' "$MEMORY_FILE"
echo
echo "--- config.yaml ---"
sed -n '1,220p' "$CONFIG_FILE"
echo "=== end payload ==="
echo
echo "simulation: pass this payload to your local router CLI, execute one handoff, then let the synthesizer update .ai/memory.md"
