#!/bin/bash
set -euo pipefail

fail() {
  local msg="$1"
  printf '{"version":"0","status":"error","message":"%s","copyable":false,"qr":false}\n' "$msg"
  exit 1
}

SRC="/mnt/lnd-source"
DST="/root/.lnd"
ts="$(date +%F-%H%M%S)"

[ -d "$SRC" ] || fail "Source volume /mnt/lnd-source not found"
[ -f "$SRC/data/chain/bitcoin/mainnet/wallet.db" ] || fail "Source wallet.db not found"
[ -f "$SRC/data/graph/mainnet/channel.db" ] || fail "Source channel.db not found"

mkdir -p "$DST"

if [ -d "$DST/data" ] || [ -f "$DST/lnd.conf" ]; then
  cp -a "$DST" "${DST}.backup-before-import-${ts}" || fail "Failed to create destination backup"
fi

rsync -aHAX --delete "${SRC}/" "${DST}/" || fail "rsync import failed"

printf '{"version":"0","status":"success","message":"Import from Start9 LND completed","copyable":false,"qr":false}\n'
