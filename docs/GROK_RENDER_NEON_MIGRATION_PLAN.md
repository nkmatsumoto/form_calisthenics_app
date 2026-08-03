# Grok execution plan: migrate Form Calisthenics to Render and Neon

## Mission

Execute the complete migration of the existing Rails application from Heroku to a zero-cost Render + Neon archive deployment. Do not stop after producing instructions. Make the code changes, create the automation, run the rehearsals, deploy the app, migrate and verify the data, document the result, and prepare the Heroku shutdown.

The owner intends to rebuild the product separately. This repository and deployment must remain a faithful, functioning reference version of the original Le Wagon project.

Automation is the default. Use CLI/API tools, repository scripts, Render Blueprint infrastructure, and browser automation as appropriate. Ask the owner only when credentials are unavailable, an account requires human authentication, a secret must be entered, service interruption is about to begin, or an irreversible deletion needs approval. After a checkpoint is resolved, resume execution instead of handing the remaining steps back to the owner.

## Definition of done

Do not declare the migration complete until all of the following are true:

- `master` contains the reviewed migration code, automation, tests, and documentation.
- A Free Render Docker Web Service in Ohio deploys the expected `master` commit.
- A separate Neon Free project holds the production PostgreSQL 16 database.
- The final source and target database inventories match, including every row count, migration version, sequence, foreign key, and index.
- Existing Devise users can sign in without password resets.
- Existing workouts, sessions, exercise sets, calendars, dashboards, searches, charts, and comparisons work.
- All 33 Active Storage records still resolve to their existing Cloudinary videos.
- A new browser-recorded workout video can be uploaded, replayed, and compared on Render.
- `/up` returns HTTP 200 and Render logs contain no new application, database, Cloudinary, or boot errors.
- Independent backups, checksums, inventories, and the final migration report exist outside Git.
- The owner has been shown a precise Heroku cleanup preview and asked for explicit approval.
- Heroku resources are deleted only if that approval is given. If approval is withheld, clearly report the remaining Heroku cost.

## Confirmed starting state (2026-08-02)

### Repository and application

| Item | Confirmed value |
| --- | --- |
| GitHub repository | `nkmatsumoto/form_calisthenics_app` |
| Default branch | `master` |
| Current commit | `211a4fe` |
| Open GitHub pull requests | none |
| Heroku app | `form-calisthenics-app` |
| Heroku URL | `https://form-calisthenics-app-c128059005e4.herokuapp.com/` |
| Heroku stack | `heroku-22` |
| Rails version in lockfile | 7.1.4 |
| Ruby version | 3.1.2 |
| Health endpoint | `GET /up` already exists |
| Upload service | Cloudinary through Active Storage |
| Authentication | Devise database authentication |

The current test files are generated placeholders with no active assertions. A passing `rails test` alone is therefore not meaningful until migration regression tests are added.

### Heroku PostgreSQL

| Item | Confirmed value |
| --- | --- |
| Add-on | `postgresql-angular-67421` |
| Plan | Essential-0, up to $5/month |
| PostgreSQL | 16.13 |
| Size | 9.68 MB |
| Ownership | owned by and attached only to `form-calisthenics-app` |
| Heroku backups | none currently reported |
| Schema migrations | 14 |

Exact source counts captured during planning:

| Table | Rows |
| --- | ---: |
| `active_storage_attachments` | 33 |
| `active_storage_blobs` | 33 |
| `active_storage_variant_records` | 0 |
| `ar_internal_metadata` | 1 |
| `exercise_assignments` | 77 |
| `exercise_sets` | 1,229 |
| `exercises` | 77 |
| `schema_migrations` | 14 |
| `users` | 13 |
| `workout_sessions` | 61 |
| `workouts` | 9 |

The 33 attachments are all `ExerciseSet#video` records on the `cloudinary` service: 31 MP4 blobs and 2 Matroska blobs, about 981 MB in total. The PostgreSQL migration moves their metadata and keys; it must not copy, rename, or delete the Cloudinary objects.

Current Heroku config variable names are:

- `CLOUDINARY_URL`
- `DATABASE_URL`
- `LANG`
- `RACK_ENV`
- `RAILS_ENV`
- `RAILS_LOG_TO_STDOUT`
- `RAILS_SERVE_STATIC_FILES`
- `SECRET_KEY_BASE`

Never print or commit their values.

## Reference implementations to follow

Inspect the actual migration commits, not only the current working trees:

- Watch List: `../rails-watch-list`, especially commits `32e19fd`, `971f787`, `d0e0ece`, `b1113ef`, `4a10cab`, `86d8b8c`, and `9a2e5c8`.
- Car Rental: `../car-rental`, especially commits `304d655`, `f0d6812`, `12d0db3`, and documentation commit `922e4f4`.

Reuse their proven approach:

- conservative Ruby/Rails dependency upgrades;
- hardened multi-stage Docker image;
- explicit production `DATABASE_URL`;
- a version-controlled `render.yaml`;
- Free Render service with manual deploys and `/up` health checks;
- Neon PostgreSQL 16 in AWS US East 2 / Ohio;
- scoped custom-format dumps with checksums;
- rehearsal restore before final cutover;
- source-versus-target parity reports;
- application-specific smoke testing;
- separate, explicitly authorized Heroku cleanup.

Do not copy the Watch List table-prefix workaround: Form Calisthenics owns its database and uses ordinary public table names.

## Target architecture and names

Use meaningful, consistent names. Do not add `legacy` and do not leave the application database named `neondb`.

| Component | Target |
| --- | --- |
| Render workspace | `LeWagon Portfolio` |
| Render Web Service | `form-calisthenics-app` |
| Render runtime | Docker |
| Render plan | Free only |
| Render region | Ohio |
| Render branch | `master` |
| Render deploy mode | manual |
| Neon project | `form-calisthenics-app` |
| Neon plan | Free only |
| Neon region | AWS US East 2 (Ohio) |
| Neon PostgreSQL | 16 |
| Neon database | `form_calisthenics_app` |
| Neon owner role | `form_calisthenics_app_owner` |
| Health check | `/up` |

Create a separate Neon project for this app. Do not put it inside the Car Rental or Watch List Neon projects. The automatically created `neondb` database and `neondb_owner` role may remain unused; they provide no application advantage, but they are harmless. Do not delete them until the migration is verified and the owner explicitly approves cleanup.

Stop before accepting any paid upgrade. If either platform no longer permits this architecture on its Free plan, report the exact current limitation and lowest-cost alternative before continuing.

## Automation contract

Add idempotent, fail-fast migration tooling under `script/migration/`. Prefer small shell scripts plus SQL over undocumented one-off terminal commands. Every script must use `set -euo pipefail`, must never enable shell tracing, must refuse an empty URL or unexpected host/database, and must never echo credentials.

Required automation:

```text
script/migration/
├── preflight
├── capture_source
├── inventory_database
├── build_restore_list
├── restore_target
├── verify_parity
└── smoke_render
```

Also add:

- `render.yaml` as the Render source of truth;
- migration-focused Rails tests;
- a CI workflow that runs tests and a production asset compilation check;
- `docs/DEPLOYMENT.md` for steady-state operations;
- `docs/MIGRATION_REPORT.md` containing sanitized evidence and final results;
- `docs/MIGRATION_HANDOFF.md` containing current status if work pauses at an unavoidable user gate.

All reports must redact passwords and connection strings. Store database dumps and full inventories outside Git in a timestamped directory such as:

```text
/Users/nkmatsumoto/Backups/form-calisthenics-app/YYYY-MM-DD-HHMMSS
```

The scripts should accept secret values only through environment variables or secure tool input:

- `SOURCE_DATABASE_URL`
- `REHEARSAL_DATABASE_URL`
- `TARGET_DATABASE_URL`
- `RENDER_BASE_URL`

Never place a connection URL directly in a command committed to Git, a Markdown file, a screenshot, CI configuration, or a pull request.

## Phase 1: create a safe baseline

1. Create a dedicated migration branch from the latest `origin/master` and confirm the worktree is clean before editing.
2. Re-run the source inventory. Confirm the Heroku add-on is still owned by and attached only to `form-calisthenics-app`.
3. Record sanitized app, database, GitHub, config-key, schema, and row-count metadata.
4. Immediately capture a managed Heroku backup.
5. Independently capture a custom-format PostgreSQL dump with `--no-owner --no-acl` into the external backup directory.
6. Generate SHA-256 checksums and verify the dump can be listed with `pg_restore --list`.
7. Generate a restore list that includes only application objects in `public` and excludes Heroku `_heroku` objects, event triggers, extension ownership, and provider-specific objects.
8. Capture source invariants for later comparison:
   - all table counts;
   - all 14 migration versions;
   - columns and data types;
   - primary keys and sequence positions;
   - foreign keys and indexes;
   - aggregate hashes of stable, non-secret columns;
   - Active Storage service/content-type aggregates;
   - counts by exercise, workout, and user without exposing PII.

Acceptance gate:

- Two independent backups exist.
- Their checksums and sanitized inventories are recorded outside Git.
- No source data, Heroku resource, or Cloudinary object has been changed.

## Phase 2: make the Rails app portable

Keep the change set conservative and based on versions already proven in the two reference migrations.

1. Upgrade Ruby consistently in `.ruby-version`, `Gemfile`, lockfile, and `Dockerfile` to the validated 3.3.12 baseline unless a compatibility test proves a newer patch release is safer.
2. Align Rails to the validated 7.1.6 line rather than making a major Rails upgrade during hosting migration.
3. Align Puma and Cloudinary to the compatible versions demonstrated by the reference migrations.
4. Regenerate the lockfile intentionally and verify every platform entry.
5. Harden the Docker image:
   - use matching Ruby versions in every stage;
   - set `BUNDLE_WITHOUT=development:test`;
   - include `libyaml-dev` and any Node/runtime packages actually required by asset compilation;
   - keep production asset compilation with a dummy secret;
   - keep the non-root runtime user;
   - retain `bin/docker-entrypoint` and `db:prepare`;
   - run one Puma worker with five threads on the Free instance.
6. Set production database configuration explicitly to `url: <%= ENV["DATABASE_URL"] %>`.
7. Set mailer URL options from `RENDER_EXTERNAL_HOSTNAME` with HTTPS. Do not leave the current TODO hostname.
8. Preserve `force_ssl`, STDOUT logging, static-file serving, and `/up`.
9. Prove Action Cable is unused. The repository currently contains only generated channel base files and no subscriptions, while Heroku has no `REDIS_URL`. Disable the unused production cable mount or configure a single-process no-external-service adapter. Do not create a paid Redis/Key Value service merely to satisfy the generated `cable.yml`.
10. Preserve Cloudinary Active Storage behavior and the existing `raw` versus `video` playback fallback. Do not rewrite media keys or download/re-upload the archive.
11. Do not introduce unrelated product refactors, authorization redesigns, or UI changes.

Create `render.yaml` with this effective configuration:

```yaml
services:
  - type: web
    name: form-calisthenics-app
    runtime: docker
    plan: free
    region: ohio
    branch: master
    healthCheckPath: /up
    autoDeployTrigger: "off"
    envVars:
      - key: DATABASE_URL
        sync: false
      - key: CLOUDINARY_URL
        sync: false
      - key: SECRET_KEY_BASE
        sync: false
      - key: RAILS_ENV
        value: production
      - key: RAILS_MAX_THREADS
        value: "5"
      - key: RAILS_SERVE_STATIC_FILES
        value: "true"
      - key: WEB_CONCURRENCY
        value: "1"
```

Add `RAILS_MASTER_KEY` only if code inspection and a production boot prove encrypted credentials are required. Do not copy unnecessary secrets from another project.

Acceptance gate:

- `bundle check` succeeds.
- A fresh test database can be created from the committed schema.
- Production assets compile without real production secrets.
- The Docker image builds locally on the target architecture.
- The container boots with a disposable PostgreSQL database and `/up` returns 200.

## Phase 3: create meaningful automated regression coverage

The present tests have no assertions. Add a focused suite before changing production:

- anonymous home page and `/up` requests;
- Devise registration, sign-in, sign-out, and existing password-hash compatibility;
- authenticated dashboard and workout search;
- workout creation;
- workout-session creation and display;
- exercise-set creation and update;
- calendar and chart data rendering;
- exercise comparison behavior with one and two prior sessions;
- Active Storage video attachment using the test disk service;
- Cloudinary helper behavior with API calls stubbed;
- authorization redirects for anonymous users.

Do not make production Cloudinary API calls in tests. Add a production-configuration smoke test that loads the app with placeholder secrets, plus an asset-precompile check. Run these in GitHub Actions on every pull request.

Record the exact test count and result in the migration report. If a pre-existing application defect is found, separate it from migration regressions and document it; fix only defects that prevent faithful deployment or verification.

## Phase 4: provision Neon and rehearse the database migration

Automate Neon creation through an authenticated CLI/API when credentials already exist. Otherwise use browser automation in the signed-in Neon console. Do not ask the owner to click through routine forms.

1. Confirm the account is on the Free plan and has room for a separate project.
2. Create the `form-calisthenics-app` project in AWS US East 2 with PostgreSQL 16.
3. On the production branch, create role `form_calisthenics_app_owner` and database `form_calisthenics_app` owned by that role.
4. Create a child branch named `migration-rehearsal` before loading production data.
5. Obtain pooled and direct connection strings securely. Use the direct endpoint for `pg_restore`; use the pooled endpoint for Render unless Rails compatibility testing dictates otherwise.
6. Verify the rehearsal target hostname belongs to Neon, its database name is exactly `form_calisthenics_app`, and it contains no application tables.
7. Restore the public-only custom dump to the rehearsal branch. Do not run `db:schema:load` first and do not use `pg_restore --clean`.
8. Run `verify_parity` against independent source and rehearsal connections.
9. Fail on any difference in schema migrations, row counts, sequences, constraints, indexes, or expected aggregate hashes.
10. Confirm all 33 Active Storage rows retain their original keys, service name, content type, checksum, and byte size.

The verification script must produce a concise machine-readable result and a human-readable sanitized report. A non-match must exit nonzero.

Acceptance gate:

- Rehearsal restore completes without ignored errors.
- Every database parity check passes.
- No production branch data has been loaded or altered yet.

## Phase 5: deploy a Render rehearsal

Automate Render creation from `render.yaml` using the authenticated dashboard/API. The owner may need to authorize GitHub or enter secrets, but Grok must handle the rest.

1. Create the service inside the existing `LeWagon Portfolio` workspace.
2. Confirm the service is Free, Ohio, Docker, `master`, manual deploy, and `/up` health check before creation.
3. Set secret environment variables without exposing them:
   - rehearsal Neon pooled URL as `DATABASE_URL`;
   - the existing Heroku `CLOUDINARY_URL` value;
   - a securely generated or existing compatible `SECRET_KEY_BASE`.
4. Do not add `REDIS_URL` unless Phase 2 proved Action Cable is genuinely used.
5. Temporarily point the rehearsal service at the reviewed migration branch (while the committed final `render.yaml` continues to declare `master`). Confirm the deployed Git SHA; do not accept an ambiguous “latest” deployment.
6. Wait through the Free-service cold start and require `/up` to return 200.
7. Run `smoke_render`, then complete browser-driven functional checks.

Rehearsal checks must include:

- home page assets and background video;
- registration, sign-in, sign-out, and password reset page rendering;
- authenticated dashboard, search, calendar, and charts;
- existing workout, session, exercise, and exercise-set pages;
- existing video replay in both Cloudinary resource modes;
- comparison of two recorded exercise sessions;
- creation of a uniquely tagged temporary workout/session/set;
- browser camera/microphone permission, recording, Cloudinary upload, replay, and comparison on a supported device/browser;
- cold-start recovery;
- `/up` and application logs.

Track every temporary record and Cloudinary public ID created by the rehearsal. Remove only those exact temporary objects after verification; never use a broad data cleanup.

Acceptance gate:

- Rehearsal database parity passes.
- Automated tests and production smoke checks pass.
- Existing and newly uploaded videos work.
- Render logs are clean.
- The owner can inspect the rehearsal URL before cutover.

## Phase 6: merge and perform the final cutover

1. Use focused Conventional Commits and open a draft pull request containing code, automation, tests, `render.yaml`, and documentation.
2. Attach sanitized evidence: test result, Docker result, rehearsal URL, deployed SHA, `/up`, parity summary, and smoke summary.
3. Resolve CI/review issues and merge into `master`.
4. Confirm Render is configured to deploy `master` and automatic deploys remain off.
5. Schedule the cutover and warn the owner immediately before enabling Heroku maintenance mode. This is the only planned write freeze.
6. Enable Heroku maintenance mode, then capture a fresh managed backup and a fresh independent custom dump.
7. Re-run and save the final source inventory and checksum.
8. Verify the Neon production database is still the intended empty `form_calisthenics_app` database.
9. Restore the final scoped dump through the direct Neon endpoint.
10. Run full source-to-production parity. Stop and leave Heroku intact if any check fails.
11. Replace Render `DATABASE_URL` with the production Neon pooled URL and deploy the exact merged `master` SHA.
12. Run all HTTP, browser, authentication, data, Cloudinary, and log checks again.
13. Re-run target counts after smoke testing and explain only the uniquely tagged smoke-data differences.

On failure:

- do not modify or delete either source database;
- point Render back to the verified rehearsal database only for diagnosis, not as an undocumented production state;
- disable Heroku maintenance mode to restore the old app;
- document the failure and next safe retry step.

Acceptance gate:

- Final parity and smoke tests pass.
- Render serves the archive from the Neon production branch.
- Heroku remains recoverable until separately approved cleanup.

## Phase 7: cost shutdown and cleanup

Successful Render cutover alone does not stop Heroku PostgreSQL charges. Prepare a cleanup preview listing the exact resources and the consequence of each action:

- web dyno for `form-calisthenics-app`;
- Essential-0 add-on `postgresql-angular-67421`;
- Heroku app `form-calisthenics-app`.

Before asking for deletion approval, prove that the final dump and checksum exist outside Git, Neon parity passes, Render is live, and rollback instructions are written.

Then ask one explicit question naming the resources to delete. If approved, automate the exact deletions, verify that no Heroku resources remain and no charges continue accruing, and report that deletion is irreversible except through the retained backup. If not approved, leave them untouched and clearly state that the database can continue charging up to $5/month plus any dyno charges.

Neon default database/role cleanup is a separate optional action. It is not required for functionality or savings and must not be bundled with Heroku cleanup.

## Required final report

Update `docs/MIGRATION_REPORT.md` with:

- source and target architecture;
- final Git and deployed SHAs;
- backup filenames and checksums, without URLs or passwords;
- sanitized source/rehearsal/target inventories;
- exact parity result;
- automated test counts;
- smoke-test result for each workflow;
- Cloudinary attachment and playback results;
- Render and Neon service identifiers and regions;
- rollback procedure;
- Heroku cleanup status and remaining monthly cost, if any;
- known limitations such as Render Free cold starts.

Update `README.md` with the archive status, live Render URL, local setup, deployment link, and a clear note that this is the original Le Wagon Rails project retained as a reference for the future rebuild.

## Non-negotiable safety rules

- Never commit, paste, log, or screenshot credentials, database URLs, Rails secrets, user emails, or Cloudinary secrets.
- Never use the Car Rental or Watch List database for this app.
- Never restore into a nonempty or ambiguously identified target.
- Never use a blind full-cluster restore or `pg_restore --clean`.
- Never run old migrations against restored production data before checking the committed schema and migration versions.
- Never delete or rename existing Cloudinary assets.
- Never delete Heroku, Neon, or Cloudinary resources without the explicit approval required above.
- Never accept a paid platform upgrade without first reporting it to the owner.
- Never call the work complete based only on `/up`; verify real authenticated workflows and data.
- Never leave a step for the owner that Grok can safely perform with available tools.
