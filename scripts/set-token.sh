#!/usr/bin/env bash
set -euo pipefail

TOKEN_FILE="/opt/perrins-edl/.git-token"
EDL_DIR="/opt/perrins-edl"

echo ""
echo "=== Perrins EDL — GitHub Token Setup ==="
echo ""
echo "Generate a fine-grained PAT at:"
echo "  https://github.com/settings/tokens?type=beta"
echo ""
echo "Scope: mperrins-demo/EDL -> Contents (read + write)"
echo ""

read -rsp "Paste your GitHub PAT (input hidden): " PAT
echo ""

if [ -z "$PAT" ]; then
    echo "No token entered. Aborting."
    exit 1
fi

echo "$PAT" | sudo tee "$TOKEN_FILE" > /dev/null
sudo chmod 600 "$TOKEN_FILE"
sudo git -C "$EDL_DIR" config credential.helper "!f() { echo username=mperrins-demo; echo password=\$(cat $TOKEN_FILE); }; f"

echo "Token saved to $TOKEN_FILE (600 perms)"
echo ""

echo "Testing push access..."
cd "$EDL_DIR"
sudo git fetch --quiet 2>/dev/null && echo "Fetch OK — token works" || echo "FAILED — check your token"

echo ""
echo "Done. To activate, run:"
echo "  sudo sed -i 's/banaction = nginx-tarpit$/banaction = nginx-tarpit-edl/' /etc/fail2ban/jail.local"
echo "  sudo systemctl restart fail2ban"
