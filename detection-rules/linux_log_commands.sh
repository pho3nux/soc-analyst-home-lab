#!/bin/bash
# Linux Log Analysis Commands for SOC Analysts
# Tested on: ParrotOS (systemd/journald based)
# Applicable to: Any systemd Linux distro (Ubuntu, Debian, Fedora, etc.)

# ─────────────────────────────────────────────────
# SSH LOG MONITORING (systemd/journald systems)
# ─────────────────────────────────────────────────

# Live SSH log monitoring (equivalent of: tail -f /var/log/auth.log)
sudo journalctl -u ssh -f

# SSH logs since last boot
sudo journalctl -u ssh -b

# All SSH logs with timestamps (ISO format)
sudo journalctl -u ssh --output=short-iso

# Filter: failed password attempts only
sudo journalctl -u ssh | grep "Failed password"

# Filter: invalid user brute force
sudo journalctl -u ssh | grep "invalid user"

# Count failed attempts per source IP
sudo journalctl -u ssh | grep "Failed password" | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn

# ─────────────────────────────────────────────────
# BINARY LOG ANALYSIS (btmp, wtmp, lastlog)
# ─────────────────────────────────────────────────

# Failed login attempts (btmp) — equivalent of Windows Event ID 4625
sudo lastb | head -20

# Successful logins (wtmp) — equivalent of Windows Event ID 4624
last | head -20

# Last login per user
lastlog

# Failed logins from specific IP
sudo lastb | grep "192.168.1.135"

# ─────────────────────────────────────────────────
# /var/log FILES (Ubuntu/Debian traditional setup)
# ─────────────────────────────────────────────────

# Auth log (Ubuntu/Debian — NOT present on ParrotOS by default)
sudo tail -f /var/log/auth.log
sudo grep "Failed password" /var/log/auth.log
sudo grep "Accepted password" /var/log/auth.log

# Syslog
sudo tail -f /var/log/syslog

# Kernel messages
sudo dmesg | tail -50

# ─────────────────────────────────────────────────
# PROCESS & NETWORK INVESTIGATION
# ─────────────────────────────────────────────────

# Active network connections (who is connected right now)
ss -tnp

# All listening ports
ss -tlnp

# Established SSH sessions
ss -tnp | grep :22

# Suspicious outbound connections
ss -tnp | grep ESTABLISHED

# Running processes (look for unusual names/paths)
ps aux | grep -v "\[" | sort -k3 -rn | head -20

# Check who is logged in right now
who
w

# ─────────────────────────────────────────────────
# BRUTE FORCE DETECTION (one-liners)
# ─────────────────────────────────────────────────

# Top 10 attacking IPs (failed SSH)
sudo journalctl -u ssh | grep "Failed password" \
  | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head -10

# Attacks in last 10 minutes
sudo journalctl -u ssh --since "10 minutes ago" | grep "Failed password"

# All usernames attempted in brute force
sudo journalctl -u ssh | grep "invalid user" \
  | awk '{print $10}' | sort | uniq -c | sort -rn

# ─────────────────────────────────────────────────
# NOTES
# ─────────────────────────────────────────────────
# ParrotOS uses journald — no flat /var/log/auth.log by default
# The ssh-log-forwarder.service in this lab bridges journald to a flat file
# for Filebeat ingestion.
#
# Windows Event ID equivalents:
#   lastb (failed logins)     = Event ID 4625
#   last  (successful logins) = Event ID 4624
#   ps aux (process list)     = Event ID 4688 (new process created)
#   ss -tnp (connections)     = Network connection logs / Sysmon Event ID 3
