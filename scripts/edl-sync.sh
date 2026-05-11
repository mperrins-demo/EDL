#!/usr/bin/env bash
# EDL sync — pull from GitHub, regenerate tarpit-ips.conf (deduped), reload nginx
# Runs via cron every 5 minutes as root
set -euo pipefail

EDL_DIR="/opt/perrins-edl"
TARPIT_CONF="/etc/nginx/tarpit-ips.conf"
TARPIT_TMP="/tmp/tarpit-ips.conf.new"

cd "$EDL_DIR"

# Pull latest (fast-forward only)
git pull --ff-only --quiet 2>/dev/null || true

# Generate tarpit-ips.conf from combined list — deduped, sorted
{
    echo "# Auto-generated from EDL — do not edit"
    echo "# Last sync: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "# Source: https://github.com/mperrins-demo/EDL"
    cat lists/tarpit-ipv4.txt lists/tarpit-ipv6.txt 2>/dev/null \
        | grep -v '^#' \
        | grep -v '^$' \
        | sort -u \
        | awk '{print $1 " 1;"}'
} > "$TARPIT_TMP"

# Only reload if changed
if ! diff -q "$TARPIT_TMP" "$TARPIT_CONF" >/dev/null 2>&1; then
    cp "$TARPIT_TMP" "$TARPIT_CONF"
    if nginx -t 2>/dev/null; then
        systemctl reload nginx
    else
        echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) nginx config test failed after EDL sync" >> /var/log/edl-sync.log
    fi
fi

rm -f "$TARPIT_TMP"
