# External Skills

This directory is intentionally source-driven.

`caveman.md` and `ponytail.md` are not authored in this repository. The scaffold tool downloads the latest skill Markdown from configured sources at install time.

The default upstream repositories are intentionally used because they are already structured to work across many harnesses. They carry native files for agent CLIs, editors, plugin systems, and command surfaces, so this project only needs to mount the latest skill Markdown into `.ai/skills/`.

## Install

```sh
./bin/ai-scaffold --target /path/to/repo --skills latest
```

By default, the scaffold downloads:

- `https://raw.githubusercontent.com/JuliusBrussee/caveman/main/skills/caveman/SKILL.md`
- `https://raw.githubusercontent.com/DietrichGebert/ponytail/main/skills/ponytail/SKILL.md`

Override the sources with explicit URLs:

```sh
./bin/ai-scaffold --target /path/to/repo --skills latest \
  --caveman-url https://example.com/caveman.md \
  --ponytail-url https://example.com/ponytail.md
```

Or use environment variables:

```sh
CAVEMAN_SKILL_URL=https://example.com/caveman.md \
PONYTAIL_SKILL_URL=https://example.com/ponytail.md \
./bin/ai-scaffold --target /path/to/repo --skills latest
```

## Local Development

For offline testing, use local files:

```sh
./bin/ai-scaffold --target /path/to/repo --skills latest \
  --caveman-url file:///absolute/path/to/caveman.md \
  --ponytail-url file:///absolute/path/to/ponytail.md
```

## Contract

Downloaded skill files should land at:

- `.ai/skills/caveman.md`
- `.ai/skills/ponytail.md`

The router and adapters reference those paths, but the skill content remains externally owned.
