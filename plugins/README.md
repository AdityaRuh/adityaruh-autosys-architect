# Plugins

Hermes plugins are optional extensibility units that drop in under `~/.hermes/plugins/`. They come in four flavors:

- **General plugins** — add tools, hooks, slash commands, or skills.
- **Memory providers** — replace bounded `MEMORY.md` with an external store.
- **Context engines** — replace Hermes's default context compression strategy.
- **Model providers** — register new providers/models.

## Recommended plugins for AutoSys Architect

- **filesystem-mcp** — Read approved project directories for repository-aware architecture analysis and dependency mapping. *(required)*
- **web-search-mcp** — Research architecture patterns, benchmarks, infrastructure options, and current best practices. *(required)*
- **github-mcp** — Inspect approved remote repository context when GitHub analysis is requested or provided. *(optional)*
- **mermaid** — Render architecture and dependency diagrams for CLI-friendly explanation. *(required)*

## Installing a plugin

```bash
hermes plugins install <id>
hermes plugins enable <id>
hermes plugins list
```

## Safety

- Project-scoped plugins (`<repo>/.hermes/plugins/`) require `HERMES_ENABLE_PROJECT_PLUGINS=true` and a manual review of the plugin's code.
- Hermes does not auto-update plugins. Pin to versions you have audited.
- User-installed memory and context-engine plugins are **disabled by default** — turn them on explicitly under `plugins.enabled` in `config/config.yaml`.
