# Perrins EDL (External Dynamic List)

Automatically maintained blocklists of scanner and attacker IPs observed across Perrins-managed infrastructure. Updated in real time as detections occur.

## Lists

| File | Description |
|------|-------------|
| `lists/tarpit-ipv4.txt` | IPv4 addresses, one per line |
| `lists/tarpit-ipv6.txt` | IPv6 addresses, one per line |
| `lists/tarpit-ips-all.txt` | Combined IPv4 + IPv6 (auto-generated) |

Each list is plain text, one address per line. Lines starting with `#` are comments. Suitable for ingestion by firewalls, WAFs, geo blocks, or any system that consumes IP blocklists.

## Audit log

`tarpit-log.csv` records every ban and unban event with timestamp, detection category, ban duration, and address family.

## Detection categories

| Category | Description |
|----------|-------------|
| `nginx-wordpress` | WordPress login/admin probing |
| `nginx-configprobe` | Scanning for .env, .git/config, config files |
| `nginx-traversal` | Path traversal attempts |
| `nginx-shellinjection` | Shell injection in request parameters |
| `nginx-sqli` | SQL injection attempts |
| `nginx-botsearch` | Automated vulnerability scanners |
| `nginx-4xx-catchall` | High volume 4xx error generation |

## How to consume

Raw file URLs for automated ingestion:

```
https://raw.githubusercontent.com/mperrins-demo/EDL/main/lists/tarpit-ipv4.txt
https://raw.githubusercontent.com/mperrins-demo/EDL/main/lists/tarpit-ipv6.txt
https://raw.githubusercontent.com/mperrins-demo/EDL/main/lists/tarpit-ips-all.txt
```

Git history serves as the full audit trail — every addition and removal is a commit.
