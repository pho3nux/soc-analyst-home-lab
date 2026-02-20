# SOC Analyst Home Lab Portfolio

## Repository Structure

```
soc-analyst-home-lab/
├── README.md
├── incidents/
│   ├── INC-001_ssh_brute_force.md
│   ├── INC-002_c2_beaconing.md
│   └── INC-003_port_scan.md
└── detection-rules/
    ├── ssh_brute_force.kql
    ├── wireshark_filters.txt
    └── linux_log_commands.sh
```

---

Detection engineering, SIEM pipeline, and incident analysis from a hands-on home lab environment.

## Lab Environment

| Component | Details |
|-----------|---------|
| SIEM | Elastic Stack (Elasticsearch + Kibana) on Ubuntu Server 22.04 |
| Endpoint | ParrotOS (Debian-based) |
| Log Shipper | Filebeat 8.x |
| Virtualisation | UTM on Apple M1 |
| Network | Host-only, LAN: 192.168.1.0/24 |

### Pipeline Architecture

```
ParrotOS (journald)
    ↓  ssh-log-forwarder.service
    ↓  /var/log/custom/auth.log
    ↓  Filebeat
    ↓  Elasticsearch (192.168.1.134:9200)
    ↓  Kibana Dashboard
```

---

## Incident Reports

| ID | Title | Severity | Technique |
|----|-------|----------|-----------|
| [INC-001](incidents/INC-001_ssh_brute_force.md) | SSH Brute Force Attack | Medium | T1110.001 |
| [INC-002](incidents/INC-002_c2_beaconing.md) | Suspected C2 Beaconing | High | T1071.001 |
| [INC-003](incidents/INC-003_port_scan.md) | Network Port Scan | Low–Medium | T1046 |

---

## Detection Rules

| File | Platform | Detects |
|------|----------|---------|
| [ssh_brute_force.kql](detection-rules/ssh_brute_force.kql) | Kibana / Elastic | SSH brute force / password spraying |
| [wireshark_filters.txt](detection-rules/wireshark_filters.txt) | Wireshark | C2 beaconing, port scans, exfiltration |
| [linux_log_commands.sh](detection-rules/linux_log_commands.sh) | Linux CLI | Failed logins, SSH analysis |

---

## Skills Demonstrated

- **SIEM**: Elastic Stack — Elasticsearch, Kibana, KQL, data views, dashboards
- **Log Pipeline**: systemd service → flat file → Filebeat → Elasticsearch (end-to-end build)
- **Log Analysis**: journalctl, lastb, auth.log patterns, SSH failure identification
- **Packet Analysis**: Wireshark filters, TCP stream reconstruction, C2 and scan detection
- **Threat Intelligence**: MITRE ATT&CK mapping, IoC enrichment (VirusTotal, AbuseIPDB)
- **Incident Response**: NIST IR framework, triage, timeline construction, escalation logic
- **Frameworks**: MITRE ATT&CK, NIST IR, Cyber Kill Chain
