# Migration handoff

Current status for the Form Calisthenics Render + Neon migration.

## Done

- Branch `codex/render-neon-migration` with portable Rails/Docker/`render.yaml` changes
- Migration scripts under `script/migration/`
- Regression tests (22 passing) and GitHub Actions CI workflow
- External backups + sanitized inventories in `/Users/nkmatsumoto/Backups/form-calisthenics-app/2026-08-02-200457`
- Neon project `form-calisthenics-app` (`holy-hill-12774116`) in AWS US East 2
- Role `form_calisthenics_app_owner` and database `form_calisthenics_app`
- Rehearsal branch `migration-rehearsal` restored with full parity PASS

## In progress / next gates

1. Push branch and open draft PR with sanitized evidence
2. Create Render Free Docker service in workspace `LeWagon Portfolio`
3. Set secrets from Heroku (`CLOUDINARY_URL`, `SECRET_KEY_BASE`) and rehearsal Neon pooled `DATABASE_URL`
4. Temporarily deploy the migration branch SHA, run `smoke_render` and browser checks
5. Merge to `master`, freeze Heroku writes, final dump/restore to Neon production branch, switch Render `DATABASE_URL`, redeploy exact `master` SHA
6. Ask for explicit approval before deleting Heroku resources

## Credentials needed only at gates

- Render env var entry if CLI cannot set secrets from local Heroku config without confirmation
- Explicit approval before Heroku maintenance mode and before irreversible Heroku deletion
