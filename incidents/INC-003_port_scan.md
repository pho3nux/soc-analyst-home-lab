# INC-003 — Network Port Scan Detected

| Field | Value |
|-------|-------|
| **Incident ID** | INC-003 |
| **Date** | 2026-02-17 |
| **Severity** | Low–Medium |
| **Status** | Resolved (Lab) |
| **MITRE Techniques** | T1046, T1595.001 |
| **Detection Source** | Wireshark — SYN packet anomaly |

## Executive Summary

A TCP SYN port scan was detected against the lab network originating from the analyst machine using Nmap. Identified through Wireshark by detecting a burst of SYN packets with no corresponding ACK responses — the hallmark of an Nmap default SYN scan (`-sS`). Scan completed across 1000 common ports in under 2 seconds.

## Detection

Wireshark display filter used to isolate the scan:
```
tcp.flags.syn == 1 and tcp.flags.ack == 0
```

This isolates half-open SYN packets — the signature of a SYN scan. In a standard SYN scan the scanner sends SYN but never completes the TCP handshake, making it faster and stealthier than a full connect scan.

## Packet Analysis Findings

- Burst of SYN packets from single source IP across wide port range in rapid succession
- SYN-RST responses for closed ports (target rejects the half-open connection)
- SYN-SYN/ACK for open ports (scanner receives the response but sends no ACK)
- ~1000 ports scanned in under 2 seconds — far beyond human interaction speed
- No follow-up exploitation attempts observed during this session

## MITRE ATT&CK Mapping

| Technique | Name | Description |
|-----------|------|-------------|
| T1046 | Network Service Discovery | Nmap SYN scan to enumerate open ports and services |
| T1595.001 | Active Scanning: Scanning IP Blocks | Systematic port range scan to map attack surface |

## Response Actions (Production)

1. Correlate source IP against threat intel feeds (AbuseIPDB, VirusTotal)
2. Block source IP at perimeter if scan is external and unprompted
3. Review firewall logs for follow-up connection attempts from same source
4. If internal source: investigate endpoint for compromise or rogue user
5. Note: port scan = reconnaissance only — monitor for follow-up exploitation attempts

## Lessons Learned

- SYN scan detection is straightforward with packet capture but requires an IDS (Snort/Suricata) for automated alerting at scale
- Port scans are often precursors to exploitation — detection should trigger enhanced monitoring of the source IP
- Adding Suricata or Zeek to the lab would automate this without manual Wireshark review
