# Production deployment and migration

This runbook documents the Render and Neon archive environment for Form Calisthenics. Never paste credentials, database passwords, connection URLs, Rails keys, or Cloudinary URLs into issues, pull requests, logs, or Git.

## Architecture

| Component | Production service |
| --- | --- |
| Source repository | `nkmatsumoto/form_calisthenics_app`, branch `master` |
| Rails application | Free Render Docker Web Service, Ohio |
| PostgreSQL | Neon Free, PostgreSQL 16, AWS US East 2 |
| Production database | `form_calisthenics_app`, owned by `form_calisthenics_app_owner` |
| Neon project | `form-calisthenics-app` |
| Video storage | Cloudinary through Active Storage |
| Health endpoint | `GET /up` |

The Render service uses the repository's multi-stage `Dockerfile`. Its entrypoint runs `bin/rails db:prepare` before starting Rails. Restored production databases already contain `ar_internal_metadata`, so prepare does not re-seed.

Action Cable is unused. Production uses the `async` adapter and does not require Redis.

## Render configuration

The version-controlled service definition is [`render.yaml`](../render.yaml):

- runtime: Docker
- plan: Free
- region: Ohio
- source branch: `master`
- health check: `/up`
- automatic deployment: off

Configure these values as secret environment variables in the Render dashboard:

- `DATABASE_URL` (Neon pooled connection string)
- `CLOUDINARY_URL`
- `SECRET_KEY_BASE`

Render supplies `RENDER_EXTERNAL_HOSTNAME` and `PORT` automatically. Do not duplicate or hard-code them.

## Deploying a release

1. Merge the reviewed pull request into `master`.
2. Open the `form-calisthenics-app` Web Service in Render.
3. Confirm **Settings → Build → Branch** is `master`.
4. Select **Manual Deploy → Deploy latest commit**.
5. Confirm the deployment checks out the expected `master` commit.
6. Wait until the deployment status is **Live** and `/up` returns HTTP 200.
7. Run the production smoke tests below.

Free Render services can spin down after inactivity, so the first request may take up to approximately one minute.

## Production smoke tests

After every deployment, verify:

1. The home page loads with assets and background video.
2. Devise sign-in, sign-out, and password-reset pages render.
3. An existing user can authenticate without a password reset.
4. Dashboard, search, calendar, and workout/session pages load.
5. Existing Cloudinary videos replay (`raw` and `video` resource modes).
6. Exercise comparison with prior sessions works.
7. A temporary uniquely tagged workout/session/set can be created, recorded, uploaded, and compared.
8. `GET /up` returns HTTP 200.
9. Render logs contain no new application, database, or Cloudinary errors.

Remove only the temporary smoke-test records and Cloudinary objects created for verification.

## Database backup and restore

Use the scripts under [`script/migration/`](../script/migration/). Prefer PostgreSQL 16 clients (the scripts use `postgres:16` via Docker when available).

```bash
export SOURCE_DATABASE_URL='...'   # never commit this
export HEROKU_APP=form-calisthenics-app
./script/migration/capture_source

export REHEARSAL_DATABASE_URL='...' # Neon direct endpoint, empty app DB
MODE=rehearsal \
  DUMP_FILE="$BACKUP_DIR/form-calisthenics-custom.dump" \
  LIST_FILE="$BACKUP_DIR/form-calisthenics-public-only.list" \
  ./script/migration/restore_target

SOURCE_JSON=$BACKUP_DIR/source_inventory.json \
TARGET_JSON=$BACKUP_DIR/rehearsal_inventory.json \
  ./script/migration/verify_parity
```

Restore only into an empty, explicitly verified `form_calisthenics_app` database. Do not use `pg_restore --clean`. Do not run `db:schema:load` before restore.

## Rollback

1. Keep the Heroku app and Essential-0 database intact until cleanup is explicitly approved.
2. Point Render `DATABASE_URL` back only for diagnosis, not as an undocumented production state.
3. Disable Heroku maintenance mode to restore the previous public surface.
4. Retain the external backup directory checksums for forensic restore onto a fresh Neon database.

## Known limitations

- Render Free cold starts can take up to about one minute.
- Devise registration currently requires `username`, but the stock sign-up form does not collect it (pre-existing defect).
- `workouts#index` can error when rendering `shared/workout_card` because `index` is undefined (pre-existing defect).
