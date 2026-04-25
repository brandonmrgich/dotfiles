# Hosts

## MacBook Pro M1

- **Hostname:** Brandons-MacBook-Pro.local
- **Hardware:** Apple M1, 16GB RAM, 1TB SSD
- **OS:** macOS 15.6.1 (24G90)
- **Tailscale:** m1-macbook (tail2c0e11.ts.net)
- **SSH key (outbound):** ~/.ssh/ (various per-host keys)
- **Purpose:** Primary development machine, Logic Pro, music production
- **Always on:** No (laptop)
- **Services running:** None persistent; all dev is local/ephemeral

## Debian MacBook 2012

- **Hostname:** macbook-intel-2012-debian
- **Hardware:** Intel Core i5 (gen 4), 16GB RAM, Samsung 860 EVO ~320GB (partition)
- **OS:** Debian 13 / Linux 6.12.74 amd64
- **Tailscale:** debian-macbook (tail2c0e11.ts.net)
- **SSH:** `ssh brandon@debian-macbook` · key: ~/.ssh/debian-macbook
- **Purpose:** Always-on agent host; Gastown multi-agent orchestration planned
- **Always on:** Yes
- **Services running:** None currently; Gastown stack under development

## Raspberry Pi 4

- **Hostname:** DietPi
- **Hardware:** Raspberry Pi 4, 8GB RAM
- **OS:** DietPi / Linux 6.12.75 aarch64 (Debian-based)
- **Tailscale:** pi · Tailscale IP: 100.78.214.27
- **SSH:** `ssh dietpi@pi` · key: ~/.ssh/pi-key
- **Purpose:** Network DNS — Pi-hole filtering + Unbound recursive resolver
- **Always on:** Yes
- **Services running:** Pi-hole (web UI: http://100.78.214.27/admin), Unbound (127.0.0.1:5335)
- **Note:** MVP config, early stage — much room for improvement

## Oracle Cloud (legacy)

- **Hostname:** instance-20230401-new
- **Hardware:** Ampere A1 aarch64 (shape unknown — free tier)
- **OS:** Oracle Linux 8 / Linux 5.15.0 aarch64
- **Tailscale:** not enrolled
- **Public IP:** 129.213.56.229
- **SSH:** `ssh opc@oracle` · key: ~/.ssh/oracle-cloud
- **Purpose:** Legacy standby — no active services; reserved for future use
- **Always on:** Yes

## AWS EC2

- **Hostname:** ip-172-31-91-143
- **Hardware:** t3.medium (2 vCPU, 4GB RAM)
- **OS:** Ubuntu 24.04 / Linux 6.17.0 x86_64
- **Tailscale:** not enrolled
- **Public IP:** Elastic IP (static)
- **SSH:** `ssh ubuntu@aws` · key: ~/.ssh/aws-instance.pem
- **Purpose:** MusicPlatform production backend
- **Always on:** Yes
- **Services running:** see services.md — Nginx, Fastify API, PostgreSQL (all Docker Compose)
