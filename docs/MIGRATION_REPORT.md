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
| Neon production branch | `main` (`br-spring-brook-ay50hesa`) |
| Media | Existing Cloudinary Active Storage keys retained (no re-upload) |

## Git and deployed SHAs

| Item | Value |
| --- | --- |
| Merged PR | https://github.com/nkmatsumoto/form_calisthenics_app/pull/71 |
| Merged `master` SHA | `ef5605545690b7f595cdbf3ea4e4629e0b8d0e6e` |
| Deployed Render SHA | `ef5605545690b7f595cdbf3ea4e4629e0b8d0e6e` |
| Render URL | https://form-calisthenics-app.onrender.com |
| Render service id | `srv-d9nu50jncjis73at11t0` |
| Render branch | `master` |
| Render auto-deploy | off |
| Ruby / Rails | 3.3.12 / 7.1.6 |

## Final cutover backups (outside Git)

Directory: `/Users/nkmatsumoto/Backups/form-calisthenics-app/2026-08-02-204818-cutover`

| Artifact | SHA-256 |
| --- | --- |
| `heroku-managed-final.dump` | `5044cd15dac212f35bac58dbf29df5f851ae62ecf7ab0ea7c1e45cac2821e857` |
| `form-calisthenics-final-custom.dump` | `1bb7d0e1a1d93e29c9bbc454acc047c8fb16b1ede660061176e45e70e36b2efd` |

Also present: `form-calisthenics-final-public-only.list`, `source_inventory.json`, `target_inventory.json`, `parity_result.json`.

Earlier rehearsal backups remain under `2026-08-02-200457/`.

## Sanitized inventories (final)

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

Final source (Heroku) → target (Neon `main` / `form_calisthenics_app`):

**Status: PASS**

Checked migrations, table set, every row count, sequences, foreign keys, indexes, application columns, Active Storage aggregates/keys hash, and stable non-PII content hashes.

## Automated tests

- Local / CI: **22 runs, 66 assertions, 0 failures**
- Workflow: `.github/workflows/ci.yml`

Pre-existing defects (not migration regressions):

- Devise registration form omits required `username`
- `workouts#index` can raise when rendering `shared/workout_card` (`undefined local variable or method index`)

## Smoke-test results (post-cutover)

| Workflow | Result |
| --- | --- |
| `/up` | PASS (HTTP 200) |
| Home / Devise pages / auth redirect | PASS |
| Authenticated dashboard, calendar, workout sessions | PASS |
| Existing session show, exercise compare, video exercise set | PASS |
| Temporary tagged workout `CUTOVER_SMOKE_20260802` create + delete | PASS |
| Temporary smoke user create + delete | PASS |

During smoke, counts briefly included the tagged smoke user/workout (+1 user, +1 workout) and one untagged cutover-time `workout_sessions` row (`id=760`). After cleanup of the tagged smoke records and deletion of session `760`, counts matched the final inventory above.

## Rollback procedure

1. Heroku app remains in maintenance mode with Essential-0 database intact.
2. External final dumps + checksums exist under the cutover backup directory.
3. To roll back public traffic: disable Heroku maintenance mode and point users at the Heroku URL.
4. Render can be pointed back at a verified Neon branch only for diagnosis.

## Heroku cleanup status

**Not deleted.** Explicit deletion approval is still required.

Remaining cost while retained:

- Essential-0 PostgreSQL (`postgresql-angular-67421`): up to about **$5/month**
- Web dyno for `form-calisthenics-app` if left enabled (currently under maintenance)

## Known limitations

- Render Free cold starts (up to ~1 minute)
- Neon Free compute may suspend after inactivity
- This archive is a faithful reference of the Le Wagon project, not the future rebuild
