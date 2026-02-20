# INC-002 — Suspected C2 Beaconing

| Field | Value |
|-------|-------|
| **Incident ID** | INC-002 |
| **Date** | 2026-02-17 |
| **Severity** | High |
| **Status** | Simulated / Confirmed Benign (Lab) |
| **MITRE Techniques** | T1071.001, T1041, T1132.001, T1029 |
| **Detection Source** | Wireshark — anomaly detected during traffic analysis |

## Executive Summary

Wireshark packet analysis revealed regular-interval outbound HTTP GET requests from the ParrotOS host, with base64-encoded system information embedded in URL parameters. The traffic pattern — fixed 30-second intervals, consistent user-agent, encoded payload — matches known C2 beaconing behaviour. Confirmed as simulated attack via custom bash script.

## Detection

Analyst identified suspicious traffic during routine Wireshark session using:
```
http.request
```

Packets showed HTTP GET requests to an external host at regular ~30-second intervals with `?data=` parameters containing base64-encoded content.

## Indicators of Compromise

| Indicator | Value |
|-----------|-------|
| Beacon interval | ~30 seconds (fixed) |
| Protocol | HTTP (port 80) |
| Encoding | Base64 in GET parameters |
| Pattern | Regular regardless of server response |
| Data sent | Hostname, OS version, current user (simulated) |

## Wireshark Filters Used

```
http.request                          # Isolated all outbound HTTP — revealed interval pattern
http.request.uri contains "?data="   # Identified base64 payload in URI
ip.addr == [C2 host]                  # Isolated all C2 traffic
```

TCP stream reconstruction (Follow > TCP Stream) confirmed the full beaconing structure including headers and encoded payload.

## MITRE ATT&CK Mapping

| Technique | Name | Description |
|-----------|------|-------------|
| T1071.001 | Application Layer Protocol: Web | HTTP used as C2 channel to blend with normal traffic |
| T1041 | Exfiltration Over C2 Channel | System info encoded and sent via URL parameters |
| T1132.001 | Data Encoding: Standard Encoding | Base64 used to obfuscate payload |
| T1029 | Scheduled Transfer | Fixed-interval beaconing mimicking automated check-in |

## Response Actions (Production)

1. Block destination IP/domain at perimeter firewall and web proxy
2. Isolate affected endpoint from network immediately
3. Capture full memory dump for forensic analysis
4. Search SIEM for other hosts communicating with same C2 infrastructure
5. Submit C2 IP/domain to VirusTotal and AbuseIPDB for threat intel enrichment
6. Escalate to Tier 2 / IR team as potential active compromise

## Lessons Learned

- C2 beaconing is distinguishable by regularity — interval analysis is a reliable detection method
- Base64 in URLs is a red flag but not proof of malice; context and pattern matter
- HTTP beaconing can evade basic firewall rules; SSL inspection needed to catch HTTPS variants
- Adding Suricata/Zeek to the lab would automate this detection without manual Wireshark review
