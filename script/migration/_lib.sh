#!/usr/bin/env bash
# Shared helpers for Form Calisthenics migration scripts.
# Never enable shell tracing. Never echo credentials.

set -euo pipefail

redact() {
  local text="${1:-}"
  text="${text//${SOURCE_DATABASE_URL:-__no_source__}/[REDACTED_SOURCE_DATABASE_URL]}"
  text="${text//${TARGET_DATABASE_URL:-__no_target__}/[REDACTED_TARGET_DATABASE_URL]}"
  text="${text//${REHEARSAL_DATABASE_URL:-__no_rehearsal__}/[REDACTED_REHEARSAL_DATABASE_URL]}"
  printf '%s' "$text"
}

die() {
  printf 'ERROR: %s\n' "$(redact "$*")" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

require_env() {
  local name="$1"
  local value="${!name:-}"
  [[ -n "$value" ]] || die "$name is empty or unset"
}

# Parse host and database from a postgres URL without printing secrets.
db_host() {
  python3 - "$1" <<'PY'
import sys
from urllib.parse import urlparse
u = urlparse(sys.argv[1])
print(u.hostname or "")
PY
}

db_name() {
  python3 - "$1" <<'PY'
import sys
from urllib.parse import urlparse
u = urlparse(sys.argv[1])
name = (u.path or "").lstrip("/")
print(name.split("?")[0])
PY
}

assert_neon_url() {
  local url="$1"
  local label="$2"
  local host db
  host="$(db_host "$url")"
  db="$(db_name "$url")"
  [[ -n "$host" ]] || die "$label host is empty"
  [[ "$host" == *neon.tech ]] || die "$label host is not a Neon hostname"
  [[ "$db" == "form_calisthenics_app" ]] || die "$label database must be form_calisthenics_app (got: $db)"
}

assert_source_url() {
  local url="$1"
  local host
  host="$(db_host "$url")"
  [[ -n "$host" ]] || die "SOURCE_DATABASE_URL host is empty"
  if [[ "$host" != *amazonaws.com && "$host" != *heroku* && "$host" != *neon.tech ]]; then
    die "SOURCE_DATABASE_URL host looks unexpected"
  fi
}

psql_q() {
  local url="$1"
  local sql="$2"
  local out
  if ! out="$(psql "$url" -v ON_ERROR_STOP=1 -At -F '|' -c "$sql" 2>&1)"; then
    die "psql failed: $(redact "$out")"
  fi
  printf '%s' "$out"
}

timestamp_utc() {
  date -u +%Y-%m-%d-%H%M%S
}

default_backup_root() {
  printf '%s' "${BACKUP_ROOT:-/Users/nkmatsumoto/Backups/form-calisthenics-app}"
}
