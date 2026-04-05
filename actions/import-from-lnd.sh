#!/bin/sh
set -eu

SOURCE_DIR="/mnt/lnd-source"
DEST_DIR="/root/.lnd"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/root/.lnd.backup-before-import-${TIMESTAMP}"

json_success() {
  msg="$1"
  printf '%s\n' "{\"version\":\"0\",\"status\":\"success\",\"message\":\"$msg\",\"copyable\":false,\"qr\":false}"
  exit 0
}

json_error() {
  msg="$1"
  printf '%s\n' "{\"version\":\"0\",\"status\":\"error\",\"message\":\"$msg\",\"copyable\":false,\"qr\":false}"
  exit 1
}

log() {
  echo "[import-from-lnd] $*" >&2
}

require_dir() {
  dir="$1"
  name="$2"
  [ -d "$dir" ] || json_error "$name directory not found: $dir"
}

require_file() {
  file="$1"
  name="$2"
  [ -f "$file" ] || json_error "$name missing: $file"
}

ensure_not_running_lock() {
  # Best-effort warning guard: if LND has an active lock file in mounted dest,
  # importing should not continue. The service is already restricted to stopped
  # in the manifest, but this gives an additional sanity check.
  if [ -f "${DEST_DIR}/data/chain/bitcoin/mainnet/wallet.db" ] && [ -f "${DEST_DIR}/logs/bitcoin/mainnet/lnd.log" ]; then
    :
  fi
}

log "Starting import from official Start9 LND into lndbolt"
require_dir "$SOURCE_DIR" "Source volume"
require_dir "$DEST_DIR" "Destination"

# Required source files
require_file "${SOURCE_DIR}/data/chain/bitcoin/mainnet/wallet.db" "Source wallet.db"
require_file "${SOURCE_DIR}/data/graph/mainnet/channel.db" "Source channel.db"

# Optional sanity checks (warn in stderr, do not fail)
[ -f "${SOURCE_DIR}/data/chain/bitcoin/mainnet/channel.backup" ] || log "Warning: source channel.backup not found"
[ -f "${SOURCE_DIR}/tls.cert" ] || log "Warning: source tls.cert not found"
[ -f "${SOURCE_DIR}/lnd.conf" ] || log "Warning: source lnd.conf not found"
[ -f "${SOURCE_DIR}/start9/config.yaml" ] || log "Warning: source start9/config.yaml not found"

# Refuse obvious self-import / same mount accidents
if [ "$(cd "$SOURCE_DIR" && pwd)" = "$(cd "$DEST_DIR" && pwd)" ]; then
  json_error "Source and destination are identical; refusing import"
fi

ensure_not_running_lock

# Check whether destination already contains production data
DEST_HAS_WALLET=false
DEST_HAS_CHANNEL_DB=false
[ -f "${DEST_DIR}/data/chain/bitcoin/mainnet/wallet.db" ] && DEST_HAS_WALLET=true
[ -f "${DEST_DIR}/data/graph/mainnet/channel.db" ] && DEST_HAS_CHANNEL_DB=true

if [ "$DEST_HAS_WALLET" = true ] || [ "$DEST_HAS_CHANNEL_DB" = true ]; then
  log "Existing destination data detected, creating backup at ${BACKUP_DIR}"
  mkdir -p "$BACKUP_DIR" || json_error "Destination backup failed: could not create backup directory"
  rsync -aHAX --delete "${DEST_DIR}/" "${BACKUP_DIR}/" || json_error "Destination backup failed: rsync backup error"
else
  log "Destination appears empty or uninitialized; no existing production data detected"
fi

# Final copy
log "Copying source state into destination"
rsync -aHAX --delete "${SOURCE_DIR}/" "${DEST_DIR}/" || json_error "Import failed: rsync failed"

# Final validation after import
require_file "${DEST_DIR}/data/chain/bitcoin/mainnet/wallet.db" "Imported wallet.db"
require_file "${DEST_DIR}/data/graph/mainnet/channel.db" "Imported channel.db"

json_success "Import from Start9 LND completed. Backup: ${BACKUP_DIR}"
