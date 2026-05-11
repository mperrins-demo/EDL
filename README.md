# Perrins EDL (External Dynamic List)

Scanner IPs caught by fail2ban across the Perrins infrastructure.

**What this is:** Every IP that trips a fail2ban jail on the Perrins Pi gets added here automatically. The Pi pulls this list every 5 minutes and regenerates its nginx tarpit config from it.

**Files:**
- `tarpit-ips.txt` — One IP per line. This is what the Pi consumes.
- `tarpit-log.csv` — Annotated history: IP, timestamp, jail, ban duration, sample request path.

**How it works:**
1. Scanner hits a Perrins client site
2. fail2ban detects the pattern (8 jails: WordPress, config probe, traversal, shell injection, SQLi, bot search, 4xx flood, SSH)
3. Ban action adds IP to local nginx tarpit + appends to this repo + pushes
4. Pi cron pulls this repo every 5 min, deduplicates, regenerates `tarpit-ips.conf`, reloads nginx
5. Scanner gets slow-dripped garbage instead of real responses

**Git history is the audit trail.** Every ban and unban is a commit.
