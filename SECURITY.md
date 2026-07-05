# Security Policy

## Supported Versions

Only the default branch is supported.

## Reporting a Vulnerability

Use GitHub private vulnerability reporting:

https://github.com/faraa2m/suture/security/advisories/new

Do not open public issues for vulnerabilities involving command execution, unsafe scaffold writes, path traversal, or compromised upstream skill URLs.

## Scope

Security-sensitive areas include:

- `bin/ai-scaffold`
- `.ai/hooks/pre-eval.sh`
- Remote skill download handling
- File path handling
- GitHub Actions workflows

## Expectations

Reports should include:

- Impact.
- Reproduction commands.
- Affected OS and shell.
- Whether network access is required.
- Suggested fix, if known.
