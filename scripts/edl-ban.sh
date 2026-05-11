#!/usr/bin/env bash
# EDL ban action — called by fail2ban on each ban
# Usage: edl-ban.sh <ip> <jail_name> <bantime>
set -euo pipefail

IP="${1:?missing IP}"
JAIL="${2:-unknown}"
BANTIME="${3:-3600}"
EDL_DIR="/opt/perrins-edl"
TARPIT_CONF="/etc/nginx/tarpit-ips.conf"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# --- 1. Add to nginx geo block (immediate effect) ---
if ! grep -qF "${IP} 1;" "$TARPIT_CONF" 2>/dev/null; then
    echo "${IP} 1;" >> "$TARPIT_CONF"
fi
nginx -t 2>/dev/null && systemctl reload nginx

# --- 2. Add to EDL repo ---
cd "$EDL_DIR"

# Determine v4 vs v6
if echo "$IP" | grep -q ':'; then
    LIST="ipv6"
else
    LIST="ipv4"
fi

# Add to specific list (skip if already present)
if ! grep -qxF "$IP" "lists/tarpit-${LIST}.txt" 2>/dev/null; then
    echo "$IP" >> "lists/tarpit-${LIST}.txt"
fi

# Rebuild combined list
cat lists/tarpit-ipv4.txt lists/tarpit-ipv6.txt 2>/dev/null \
    | grep -v '^#' | grep -v '^$' | sort -u > lists/tarpit-ips-all.txt

# Append to log
echo "${IP},${TIMESTAMP},${JAIL},${BANTIME},${LIST},ban" >> tarpit-log.csv

# --- 3. Push to GitHub (best effort) ---
git add lists/ tarpit-log.csv 2>/dev/null || true
git commit -m "ban ${IP} (${JAIL}, ${BANTIME}s)" --quiet 2>/dev/null || true
git push --quiet 2>/dev/null || true
