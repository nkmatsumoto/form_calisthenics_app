# Migration handoff

Cutover complete. Waiting only on explicit Heroku deletion approval.

## Done

- PR #71 merged to `master` at `ef56055`
- Neon production `main` database `form_calisthenics_app` restored with source parity PASS
- Render https://form-calisthenics-app.onrender.com serving `ef56055` with production Neon pooled `DATABASE_URL`
- Render branch `master`, auto-deploy off
- Heroku `form-calisthenics-app` left in **maintenance mode** (recoverable; not deleted)
- Final backups under `/Users/nkmatsumoto/Backups/form-calisthenics-app/2026-08-02-204818-cutover`

## Remaining gate

Ask owner to approve irreversible deletion of:

1. Heroku web dyno for `form-calisthenics-app`
2. Essential-0 add-on `postgresql-angular-67421`
3. Heroku app `form-calisthenics-app`

Until then, Essential-0 can continue charging up to about $5/month.
