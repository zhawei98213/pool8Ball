# Repository Guidelines

## Project Structure & Module Organization
This repository currently contains no tracked files or directories beyond the root. When you add code, keep the top-level layout predictable (for example: `src/` for source, `tests/` for tests, `assets/` for static files, `scripts/` for tooling). Update this document if the actual structure diverges.

## Build, Test, and Development Commands
No build or test tooling is configured yet. Once you add tooling, document the exact commands here (for example: `npm run dev` to start a local server, `npm test` to run the test suite). If you introduce task runners or makefiles, list the primary targets and what they do.

## Coding Style & Naming Conventions
There is no established style guide. If you introduce a formatter or linter (for example: Prettier, ESLint, Black, Ruff), document it here and make it the source of truth. Until then, keep indentation and naming consistent within each language and prefer clear, descriptive identifiers.

## Testing Guidelines
No test framework is present. When you add one, specify:
- Framework (for example: Jest, Pytest)
- Test file naming (for example: `*.spec.ts`, `test_*.py`)
- How to run tests (command and any required env vars)

## Commit & Pull Request Guidelines
There is no Git history or commit convention available in this repo. If you initialize Git, choose a convention (for example: Conventional Commits) and document it here. For pull requests, include:
- A short description of what changed and why
- Linked issues (if applicable)
- Screenshots or logs when changes affect UI or runtime behavior

## Configuration & Secrets
No configuration files are present. If the project requires environment variables, document them in a `.env.example` file and list them here. Never commit real secrets; use local `.env` files or secret managers.
