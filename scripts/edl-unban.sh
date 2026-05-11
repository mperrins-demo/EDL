#!/usr/bin/env bash
# EDL unban action — called by fail2ban when ban expires
# Usage: edl-unban.sh <ip> <jail_name>
set -euo pipefail

IP="${1:?missing IP}"
JAIL="${2:-unknown}"
EDL_DIR="/opt/perrins-edl"
TARPIT_CONF="/etc/nginx/tarpit-ips.conf"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# --- 1. Remove from nginx geo block ---
if [ -f "$TARPIT_CONF" ]; then
    sed -i "\|^${IP} 1;$|d" "$TARPIT_CONF"
    nginx -t 2>/dev/null && systemctl reload nginx
fi

# --- 2. Remove from EDL lists ---
cd "$EDL_DIR"

if echo "$IP" | grep -q ':'; then
    LIST="ipv6"
else
    LIST="ipv4"
fi

sed -i "\|^${IP}$|d" "lists/tarpit-${LIST}.txt" 2>/dev/null || true

# Rebuild combined
cat lists/tarpit-ipv4.txt lists/tarpit-ipv6.txt 2>/dev/null \
    | grep -v '^#' | grep -v '^$' | sort -u > lists/tarpit-ips-all.txt

# Log
echo "${IP},${TIMESTAMP},${JAIL},,${LIST},unban" >> tarpit-log.csv

# --- 3. Push (best effort) ---
git add lists/ tarpit-log.csv 2>/dev/null || true
git commit -m "unban ${IP} (${JAIL})" --quiet 2>/dev/null || true
git push --quiet 2>/dev/null || true
