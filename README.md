# Perrins EDL (External Dynamic List)

Scanner IPs caught by fail2ban across the Perrins infrastructure.

## Structure

```
lists/
  tarpit-ipv4.txt     # IPv4 addresses only
  tarpit-ipv6.txt     # IPv6 addresses only
  tarpit-ips-all.txt  # Combined (auto-generated)
urls/
  (future URL lists)
tarpit-log.csv        # Full audit log: IP, timestamp, jail, bantime, type, action
```

## How it works

1. Scanner hits a Perrins client site
2. fail2ban detects the pattern (8 jails)
3. Ban action adds IP to nginx tarpit + correct list file + pushes here
4. Pi cron pulls every 5 min, deduplicates, regenerates nginx config, reloads
5. Scanner gets slow-dripped garbage

Git history is the audit trail.
