#!/usr/bin/env bash

set -euo pipefail

readonly INTEGRATION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "${INTEGRATION_DIR}/.." && pwd)"
readonly CLI_BIN="${SONIC_CLI:-${ROOT_DIR}/target/release/sonic-cli}"
readonly ROUTER_ADDR="${ROUTER_ADDR:-127.0.0.1:31490}"
readonly ROUTER_PASSWORD="${ROUTER_PASSWORD:-RouterPassword}"
readonly COLLECTION="${COLLECTION:-infini-news}"
readonly MODE="${MODE:-fresh}"
readonly BATCH_DOCUMENTS="${BATCH_DOCUMENTS:-1000}"
readonly GROUP_WINDOW="${GROUP_WINDOW:-1000}"
readonly CONNECTIONS="${CONNECTIONS:-10}"
readonly SKIP_FLUSH="${SKIP_FLUSH:-false}"

if [[ ! -x "${CLI_BIN}" ]]; then
  echo "Missing ${CLI_BIN}; build sonic-cli or set SONIC_CLI." >&2
  exit 1
fi

import_args=(
  --addr "${ROUTER_ADDR}"
  --password "${ROUTER_PASSWORD}"
  --json
  import
  --file -
  --collection "${COLLECTION}"
  --mode "${MODE}"
  --batch-documents "${BATCH_DOCUMENTS}"
  --group-window "${GROUP_WINDOW}"
  --connections "${CONNECTIONS}"
)
if [[ "${SKIP_FLUSH}" == "true" ]]; then
  import_args+=(--skip-flush)
fi

python3 "${INTEGRATION_DIR}/stream_infini_news.py" "$@" |
  "${CLI_BIN}" "${import_args[@]}"
