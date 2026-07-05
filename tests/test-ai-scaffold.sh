#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SCAFFOLD="$ROOT_DIR/bin/ai-scaffold"
TMP_ROOT=${TMPDIR:-/tmp}/local-llm-orchestrator-tests-$$
PASS_COUNT=0

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT INT TERM

mkdir -p "$TMP_ROOT"

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'ok %s - %s\n' "$PASS_COUNT" "$1"
}

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

assert_file() {
  [ -f "$1" ] || fail "expected file: $1"
}

assert_no_file() {
  [ ! -e "$1" ] || fail "expected absent path: $1"
}

assert_executable() {
  [ -x "$1" ] || fail "expected executable: $1"
}

assert_contains() {
  file=$1
  text=$2
  grep -F -- "$text" "$file" >/dev/null 2>&1 || fail "expected '$text' in $file"
}

new_target() {
  name=$1
  dir="$TMP_ROOT/$name"
  mkdir -p "$dir"
  printf '%s\n' "$dir"
}

test_help_prints_usage() {
  output="$TMP_ROOT/help.txt"
  "$SCAFFOLD" --help >"$output"
  assert_contains "$output" "Usage:"
  assert_contains "$output" "--skills latest|skip"
  pass "help prints scaffold usage"
}

test_defaults_install_all_tool_adapters_without_skills() {
  target=$(new_target defaults)

  "$SCAFFOLD" --target "$target" --tool defaults --skills skip >"$TMP_ROOT/defaults.out"

  assert_file "$target/.ai/router.md"
  assert_file "$target/.ai/memory.md"
  assert_file "$target/.ai/config.yaml"
  assert_file "$target/.ai/skills/README.md"
  assert_file "$target/CLAUDE.md"
  assert_file "$target/AGENTS.md"
  assert_file "$target/GEMINI.md"
  assert_file "$target/.cursor/rules/local-llm-orchestrator.md"
  assert_file "$target/.windsurf/rules/local-llm-orchestrator.md"
  assert_executable "$target/.ai/hooks/pre-eval.sh"
  assert_no_file "$target/.ai/skills/caveman.md"
  assert_no_file "$target/.ai/skills/ponytail.md"
  pass "defaults install all adapters and skip external skills"
}

test_single_tool_installs_only_requested_adapter() {
  target=$(new_target codex-only)

  "$SCAFFOLD" --target "$target" --tool codex --skills skip >"$TMP_ROOT/codex.out"

  assert_file "$target/AGENTS.md"
  assert_no_file "$target/CLAUDE.md"
  assert_no_file "$target/GEMINI.md"
  assert_no_file "$target/.cursor"
  assert_no_file "$target/.windsurf"
  pass "single tool mode installs only requested adapter"
}

test_latest_skills_download_from_file_urls() {
  target=$(new_target latest-skills)
  sources="$TMP_ROOT/sources"
  mkdir -p "$sources"
  printf '# Caveman Latest\n\nremote caveman skill\n' >"$sources/caveman.md"
  printf '# Ponytail Latest\n\nremote ponytail skill\n' >"$sources/ponytail.md"

  "$SCAFFOLD" \
    --target "$target" \
    --tool codex \
    --skills latest \
    --caveman-url "file://$sources/caveman.md" \
    --ponytail-url "file://$sources/ponytail.md" >"$TMP_ROOT/latest.out"

  assert_file "$target/.ai/skills/caveman.md"
  assert_file "$target/.ai/skills/ponytail.md"
  assert_contains "$target/.ai/skills/caveman.md" "remote caveman skill"
  assert_contains "$target/.ai/skills/ponytail.md" "remote ponytail skill"
  pass "latest skills download from file URLs"
}

test_latest_skills_use_environment_urls() {
  target=$(new_target env-skills)
  sources="$TMP_ROOT/env-sources"
  mkdir -p "$sources"
  printf '# Env Caveman\n' >"$sources/caveman.md"
  printf '# Env Ponytail\n' >"$sources/ponytail.md"

  CAVEMAN_SKILL_URL="file://$sources/caveman.md" \
  PONYTAIL_SKILL_URL="file://$sources/ponytail.md" \
    "$SCAFFOLD" --target "$target" --tool gemini --skills latest >"$TMP_ROOT/env.out"

  assert_contains "$target/.ai/skills/caveman.md" "# Env Caveman"
  assert_contains "$target/.ai/skills/ponytail.md" "# Env Ponytail"
  pass "latest skills use environment URLs"
}

test_invalid_latest_skill_source_fails() {
  target=$(new_target invalid-skill-source)
  sources="$TMP_ROOT/invalid-sources"
  mkdir -p "$sources"
  printf '# Ponytail Exists\n' >"$sources/ponytail.md"
  output="$TMP_ROOT/invalid-skill-source.out"

  if "$SCAFFOLD" \
    --target "$target" \
    --tool codex \
    --skills latest \
    --caveman-url "file://$sources/missing-caveman.md" \
    --ponytail-url "file://$sources/ponytail.md" >"$output" 2>&1; then
    fail "expected invalid skill source failure"
  fi

  assert_contains "$output" "caveman skill file not found"
  pass "invalid latest skill source fails clearly"
}

test_pre_eval_hook_runs_after_scaffold() {
  target=$(new_target hook-run)

  "$SCAFFOLD" --target "$target" --tool codex --skills skip >"$TMP_ROOT/hook-install.out"
  "$target/.ai/hooks/pre-eval.sh" "$target" >"$TMP_ROOT/pre-eval.out"

  assert_contains "$TMP_ROOT/pre-eval.out" "local-llm-orchestrator: pre-eval"
  assert_contains "$TMP_ROOT/pre-eval.out" "=== routing payload ==="
  pass "pre-eval hook runs after scaffold"
}

test_invalid_target_fails() {
  output="$TMP_ROOT/invalid-target.out"

  if "$SCAFFOLD" --target "$TMP_ROOT/nope" --tool codex --skills skip >"$output" 2>&1; then
    fail "expected invalid target failure"
  fi

  assert_contains "$output" "target does not exist"
  pass "invalid target fails clearly"
}

test_help_prints_usage
test_defaults_install_all_tool_adapters_without_skills
test_single_tool_installs_only_requested_adapter
test_latest_skills_download_from_file_urls
test_latest_skills_use_environment_urls
test_invalid_latest_skill_source_fails
test_pre_eval_hook_runs_after_scaffold
test_invalid_target_fails

printf '1..%s\n' "$PASS_COUNT"
