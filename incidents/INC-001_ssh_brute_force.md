# INC-001 — SSH Brute Force Attack

| Field | Value |
|-------|-------|
| **Incident ID** | INC-001 |
| **Date** | 2026-02-17 |
| **Severity** | Medium |
| **Status** | Resolved (Lab) |
| **MITRE Techniques** | T1110.001, T1078, T1021.004 |
| **Detection Source** | Kibana — "SOC Lab - SSH Attack Detection" dashboard |

## Executive Summary

Automated SSH brute force attack detected against the ParrotOS endpoint. 10 failed authentication attempts in ~30 seconds against a non-existent user (`fakeuser`) from 192.168.1.135. Pattern consistent with automated credential stuffing/username enumeration.

## Detection

KQL query powering the detection dashboard:
```kql
message: "Failed password"
```

Spike of >5 events in under 1 minute triggered visual alert in Kibana time-series chart.

## Log Evidence

```
sshd: Failed password for invalid user fakeuser from 192.168.1.135 port 54321 ssh2
sshd: pam_unix(sshd:auth): authentication failure; user=fakeuser
sshd: PAM 2 more authentication failures; user=fakeuser
sshd: Disconnected from 192.168.1.135 port 54321
sshd: Failed password for invalid user fakeuser from 192.168.1.135 port 54322 ssh2
```

## Brute Force Indicators

- `invalid user` — username doesn't exist (automated wordlist)
- 10 attempts in < 30 seconds — beyond human speed
- New connection per attempt (sequential port numbers)
- Immediate reconnect after disconnect

## MITRE ATT&CK Mapping

| Technique | Name | Description |
|-----------|------|-------------|
| T1110.001 | Brute Force: Password Guessing | Repeated SSH auth attempts |
| T1078 | Valid Accounts (attempted) | Username enumeration via trial-and-error |
| T1021.004 | Remote Services: SSH | SSH as attack vector |

## Response Actions (Production)

1. Block source IP at firewall: `sudo ufw deny from 192.168.1.135`
2. Harden SSH: disable password auth, enforce key-based auth
3. Enable fail2ban SSH jail (ban after 5 failures/10 min)
4. Escalate to Tier 2 if source is external

## Lessons Learned

- Flat auth.log required for Filebeat — journald needs bridging on systemd distros
- Formal Kibana alert rule needed: >5 failures/min → automated alert
- Static IP on SIEM to prevent Filebeat breaks on reboot
