# Skills

Hermes-compatible skills for AutoSys Architect. Each skill is a directory under a category folder:

```
skills/
└── <category>/
    └── <skill-id>/
        ├── SKILL.md          # frontmatter + procedure (required)
        ├── scripts/          # optional executable helpers
        ├── references/       # long-form docs (L2 progressive disclosure)
        ├── templates/        # optional templates the skill renders
        └── assets/           # optional binaries, fonts, prompts
```

## Baseline skills shipped with this package

- `architecture/api-service-dependency-mapping` — Map APIs and service dependencies from provided project context.
- `architecture/architecture-adaptation-when-constraints-change` — Update architecture recommendations when requirements or constraints change.
- `architecture/basic-security-fault-tolerance-recommendations` — Provide baseline security and fault-tolerance architecture guidance.
- `architecture/cost-estimation` — Produce rough cost ranges and compare architecture cost posture.
- `architecture/infrastructure-recommendation-engine` — Recommend infrastructure choices aligned to maturity, budget, and reliability.
- `architecture/mermaid-diagram-generation` — Generate Mermaid diagrams for proposed or existing architectures.
- `architecture/reliability-performance-optimization-guidance` — Provide reliability and performance guidance for proposed systems.
- `architecture/repository-analysis-for-architecture-improvement` — Analyze repository structure for architecture improvement opportunities.
- `architecture/scalability-optimization-suggestions` — Suggest staged scaling improvements and architecture evolution paths.
- `architecture/smart-clarification-questioning` — Ask focused architecture questions before making final recommendations.
- `architecture/system-architecture-generation` — Generate practical production-ready system architecture recommendations and diagrams.
- `architecture/tech-stack-recommendation` — Recommend application and infrastructure stacks with clear rationale.
- `architecture/tradeoff-analysis` — Compare architecture options across complexity, cost, scale, and reliability.

These baseline skills are the fixed preapproved MVP launch set and are pinned by `install.sh`. This baseline package does not support agent-created or runtime-added skills; any later skill expansion is outside MVP scope and must be handled as a separate preapproved package update.

## SKILL.md anatomy

See the per-skill SKILL.md files for the concrete shape. Required frontmatter fields:

- `name` (matches directory name, kebab-case)
- `description` (one-line summary; shown in L0 listing ~24 tokens)
- `version` (semver)

Optional but recommended: `metadata.hermes.tags`, `metadata.hermes.requires_toolsets`, `required_environment_variables`.

Body sections (convention): **When to Use** → **Procedure** → **Pitfalls** → **Verification**.

## Template variables

Inside SKILL.md, the following are available at load time:

- `${HERMES_SKILL_DIR}` — absolute path to this skill's directory.
- `${HERMES_SESSION_ID}` — active session ID.
