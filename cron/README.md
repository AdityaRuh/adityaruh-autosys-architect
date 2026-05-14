# Cron — scheduled tasks for AutoSys Architect

`jobs.json` declares the recurring or one-shot agent tasks AutoSys Architect should run unattended. Only jobs the user explicitly approved during the build flow are included.

## Configured jobs

_No scheduled jobs were declared during the build flow. Add some with `hermes cron create` later._

## Registering jobs

```bash
hermes cron import cron/jobs.json --label autosys-architect
hermes cron list
hermes cron pause <id>
hermes cron run <id>
```

## Constraints

- Cron jobs cannot recursively schedule more cron jobs (Hermes enforces).
- `context_from` requires the upstream job to have finished within the last 24h.
- `delivery: "origin"` only works when a messaging gateway is configured.

## Curator and cron

The curator does NOT touch cron jobs. Use `hermes cron remove` to delete.
