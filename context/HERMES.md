# HERMES.md — runtime guidance for AutoSys Architect

Hermes-specific operating rules. Loaded automatically when Hermes detects this file in any working directory.

## Architecture assumptions

- **Terminal backend:** `docker` — Docker is the approved terminal backend because it isolates repository inspection and tooling from the host while supporting iterative CLI sessions, local demos, and self-hosted VPS deployment.
- **Model:** default `anthropic/claude-opus-4-7`; override per-skill in SKILL.md when a skill benefits from a different reasoning profile.
- **Memory:** bounded `MEMORY.md` (~2200 chars) and `USER.md` (~1375 chars). Use the `memory` tool's `add`/`replace`/`remove` actions — do not edit via shell.
- **Skills:** 13 baseline skill(s) ship with this package as the approved fixed MVP launch set. Treat the shipped skill set as preapproved and stable for this baseline release.

## Skill set policy

- MVP uses only the fixed launch set of preapproved skills that ship with this package.
- Do not assume runtime skill creation, runtime skill pinning, or curator review workflows are part of the shipped MVP.
- If future expansions add more skills, they must come from a separately approved package update rather than ad hoc runtime creation in this baseline profile.

## Interaction model

- **MVP channel:** CLI only.
- **External gateway behavior:** none configured in MVP.
- **DM pairing / allowlist behavior:** not applicable in MVP because no messaging gateway is enabled.
- **Chat slash commands:** not part of the approved MVP behavior.
- **Voice/media:** text-only CLI workflow; no voice or external gateway media in MVP.

## Delegation and execution

- Operate within the documented CLI workflow and approved Hermes tools/integrations.
- Do not assume any chat-only control surface, external delivery channel, or undeclared runtime tool is available.
- Do not claim or rely on any `delegate_task` behavior unless a future approved build explicitly provides and documents it.

## Safety defaults

- Approvals: `smart`.
- Terminal backend risk: Docker reduces host blast radius but does not eliminate it; mounted directories, container image choice, and approval gating still determine exposure, so the profile must stay read-oriented and non-destructive by default.
- Generated install scripts must not download arbitrary remote code at runtime.
- Skill scripts must declare every secret they read via `required_environment_variables`.
