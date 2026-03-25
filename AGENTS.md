# AGENTS.md

This file provides guidelines for agentic coding assistants working in the open.docs repository.

## Repository Structure

This is a multi-framework documentation repository containing:
- `astro.docs/` - Astro/TypeScript documentation site (primary focus)
- `fastapi.docs/` - MkDocs/Python documentation site
- `alpine.docs/` - MkDocs/JavaScript documentation site
- `python.docs/` - Generated Sphinx/Python docs (read-only)
- `php.docs/` - Generated PHP docs (read-only)

## Build Commands

### Astro Docs (astro.docs/)

```bash
cd astro.docs
pnpm dev              # Start dev server
pnpm build            # Production build
pnpm preview          # Preview production build
pnpm check            # Astro type checking
pnpm format           # Format code with Prettier
pnpm lint:eslint      # Run ESLint
pnpm lint:linkcheck   # Check all links (builds first)
pnpm lint:slugcheck   # Verify translation slugs match English
```

### FastAPI Docs (fastapi.docs/)

```bash
cd fastapi.docs
# Activate virtual environment first: source .venv/bin/activate
mkdocs serve         # Start dev server
mkdocs build         # Production build
pytest               # Run all tests
pytest path/to/test  # Run a single test file
```

### Alpine Docs (alpine.docs/)

```bash
cd alpine.docs
# Activate virtual environment first
mkdocs serve         # Start dev server
mkdocs build         # Production build
```

## Running Tests

### FastAPI Docs
FastAPI docs tests use pytest with TestClient:
```bash
cd fastapi.docs
pytest docs_src/app_testing/app_a_py310/test_main.py::test_read_main
```

### Astro Docs
No automated test suite. Use manual testing via `pnpm dev` and build verification with `pnpm build`.

## Code Style Guidelines

### TypeScript/JavaScript (astro.docs/)

**Imports:**
- Use bare specifiers for local imports with `~/` alias: `import { foo } from '~/util/bar'`
- Use `import type` for type-only imports: `import type { CollectionEntry } from 'astro:content'`
- Third-party imports first, then local imports
- No unused imports

**Formatting:**
- Use tabs for code indentation (2-width)
- Use spaces for config files (*.json, *.md, *.toml, *.yml)
- Max line width: 100 characters
- Use single quotes
- Trailing commas in ES5+ style
- Prettier handles formatting automatically
- Use `const` for variables, `let` only when reassignment needed

**Types:**
- TypeScript strict mode enabled
- Type parameters prefix with generics: `<T, U>`
- Use interfaces for object shapes that can be extended
- Use type aliases for unions, primitives, and tuples
- Export types when used across modules
- Use `as const` for literal type narrowing

**Naming Conventions:**
- camelCase for variables, functions, and methods
- PascalCase for classes, interfaces, types, and enums
- UPPER_CASE for constants
- kebab-case for file names
- Private class members: `private readonly name` with `#` for truly private (optional)
- Async functions: prefix with descriptive verb, not "async" in name

**Error Handling:**
- Use try/catch for operations that may throw
- Return early for error conditions to reduce nesting
- Validate inputs at function boundaries
- Use Astro's `AstroError` for expected errors
- Document error scenarios in JSDoc comments

**Code Organization:**
- One class/export per file preferred
- Keep utility functions in src/util/
- Components in src/components/ organized by domain
- TypeScript interfaces in same file as implementation or separate types file
- Use JSDoc comments for public API documentation

**Astro-specific:**
- Use frontmatter for component props with proper typing
- Use `Astro.props` and `Astro.slots` correctly
- Prefer `<slot />` over children props
- Use `const currentPage = new URL(Astro.request.url)` for URL handling
- For external styles, link CSS in component with scoped or global as needed
- Custom elements: register in client-side `<script>` tags
- Use Starlight components for documentation-specific UI

**CSS:**
- Scoped styles in component `<style>` blocks where possible
- Use CSS variables from Starlight theme (prefix `--sl-`)
- Global styles in dedicated global CSS files
- Use CSS Grid/Flexbox for layouts
- Prefer `data-*` attributes for component state hook-up

### Python (fastapi.docs/)

**Imports:**
- Standard library first, then third-party, then local
- Use relative imports for local modules
- Type imports with `from typing import`

**Testing:**
- Use `TestClient` for FastAPI endpoint testing
- Assert status codes and JSON responses
- Keep tests simple and focused
- Test files: `test_main.py` in app directories

## Important Notes

- The Python and PHP doc directories contain generated documentation - do NOT edit
- Astro docs has extensive i18n (12 languages) - ensure translation compatibility
- Maintain slug consistency across translations (use `pnpm lint:slugcheck`)
- For TypeScript work in astro.docs, always run `pnpm check` and `pnpm lint:eslint` before committing
- Use `pnpm run format` to ensure code style consistency
- The repo uses pnpm in astro.docs, pip for Python projects
- No automated testing for astro.docs - verify manually in dev server