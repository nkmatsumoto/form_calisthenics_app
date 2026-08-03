# Migration report: Form Calisthenics → Render + Neon

Sanitized evidence for the archive migration. No credentials, emails, or connection strings are included.

## Source and target architecture

| Item | Value |
| --- | --- |
| Source app | Heroku `form-calisthenics-app` (`heroku-22`) |
| Source database | Essential-0 add-on `postgresql-angular-67421`, PostgreSQL 16.13 |
| Target app | Render Free Docker Web Service `form-calisthenics-app`, Ohio |
| Target database | Neon Free project `form-calisthenics-app` (`holy-hill-12774116`), AWS US East 2, PostgreSQL 16 |
| Application database | `form_calisthenics_app` owned by `form_calisthenics_app_owner` |
| Media | Existing Cloudinary Active Storage keys retained (no re-upload) |

## Git and runtime baseline

| Item | Value |
| --- | --- |
| Migration branch | `codex/render-neon-migration` |
| Baseline `master` commit at branch creation | `37afa07` |
| Ruby | 3.3.12 |
| Rails | 7.1.6 |
| Puma | 6.6.x |
| Cloudinary gem | 2.4.x |
| Action Cable | unused; production adapter `async` |

## Backups (outside Git)

Directory: `/Users/nkmatsumoto/Backups/form-calisthenics-app/2026-08-02-200457`

| Artifact | SHA-256 |
| --- | --- |
| `heroku-managed.dump` | `25fecab4f28e6cb258473bfa78aa9491ce6b9acbee8b37164d6acfcf8544f208` |
| `form-calisthenics-custom.dump` (PG16 re-capture) | see `SHA256SUMS` in the backup directory |

Independent custom dump used `--no-owner --no-acl`. Restore list excludes Heroku `_heroku` objects, event triggers, and `pg_stat_statements`.

## Sanitized inventories

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

Active Storage aggregates:

- `cloudinary` / `video/mp4`: 31 blobs
- `cloudinary` / `application/x-matroska`: 2 blobs

## Parity result

Rehearsal restore onto Neon branch `migration-rehearsal` completed with:

**Status: PASS**

Checked: migrations, table set, every row count, sequences, foreign keys, indexes, application columns, Active Storage aggregates/keys hash, and stable non-PII content hashes for users/workouts/sessions/exercises/sets/assignments/blobs/attachments.

## Automated tests

Local result on PostgreSQL 16:

- **22 runs, 66 assertions, 0 failures, 0 errors, 0 skips**

Coverage includes `/up`, home, Devise auth flows, dashboard/search, workout and session creation, exercise-set create/update, calendar, compare with one/two sessions, Active Storage disk attachment, stubbed Cloudinary helper behavior, and production config/blueprint smoke checks.

CI workflow: [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) runs tests plus production asset precompile.

Documented pre-existing defects (not migration regressions):

- Devise registration form omits required `username`.
- `workouts#index` can raise when rendering `shared/workout_card` (`undefined local variable or method index`).

## Docker / boot evidence

- Production assets compile with dummy secrets.
- Docker image `form-calisthenics-app:migration` builds on `aarch64-linux`.
- Container `/up` returns HTTP 200 when `X-Forwarded-Proto: https` is supplied (Render TLS termination).

## Smoke-test and cutover status

| Workflow | Status |
| --- | --- |
| Rehearsal DB restore + parity | PASS |
| Render rehearsal deploy | in progress / pending URL |
| Authenticated browser workflows on Render | pending deploy |
| Final production Neon restore | pending cutover |
| Heroku cleanup | not approved yet |

## Rollback procedure

1. Leave Heroku app and `postgresql-angular-67421` intact.
2. Disable Heroku maintenance mode if enabled.
3. Keep Render on the verified rehearsal database only for diagnosis.
4. Re-restore from the external custom dump onto a fresh empty Neon `form_calisthenics_app` database if needed.

## Remaining cost if Heroku is retained

- Essential-0 PostgreSQL: up to about $5/month
- Web dyno charges if the Heroku dyno remains enabled

## Known limitations

- Render Free cold starts
- Neon Free compute suspends after inactivity
- Archive deployment is a faithful reference of the Le Wagon project, not the future rebuild
