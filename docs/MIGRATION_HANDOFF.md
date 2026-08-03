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

## Done since previous handoff

- Draft PR: https://github.com/nkmatsumoto/form_calisthenics_app/pull/71
- Render service live: https://form-calisthenics-app.onrender.com (`srv-d9nu50jncjis73at11t0`)
- Deployed SHA: `eb25dbb` on branch `codex/render-neon-migration`
- Rehearsal Neon pooled URL configured as Render `DATABASE_URL`
- Anonymous + authenticated rehearsal smoke checks passed; temporary smoke records removed

## Next gates (need owner approval)

1. Merge PR #71 into `master`
2. Enable Heroku maintenance mode (planned write freeze)
3. Final dump → restore into Neon production branch `form_calisthenics_app`
4. Point Render `DATABASE_URL` at production Neon pooled URL and deploy exact merged `master` SHA
5. Separate explicit approval before deleting Heroku app / Essential-0 database

## Credentials / approvals needed

- Explicit approval before Heroku maintenance mode
- Explicit approval before irreversible Heroku deletion
