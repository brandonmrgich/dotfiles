# Networks

## Tailscale

- **Tailnet:** tail2c0e11.ts.net
- **Admin:** personal account (bmrgich@gmail.com)
- **MagicDNS:** disabled — custom DNS configured instead
- **DNS via Tailscale:** Pi-hole at 100.78.214.27 (Pi's Tailscale IP)
- **Enrolled devices:** m1-macbook, debian-macbook, pi
- **Not enrolled:** Oracle Cloud, AWS EC2
- **Auth:** Google OAuth (browser flow currently; headless/0-browser auth is a future goal)
- **Note:** Tailscale-enrolled hosts are reachable from anywhere, not just LAN

## LAN

- **Router:** ISP-provided; config locked in mobile app — topology unknown
- **Subnet:** unknown
- **DHCP:** managed by router; no confirmed static LAN IPs
- **Practical implication:** Tailscale is the reliable cross-device layer for personal hosts

## DNS

- **Primary resolver:** Pi-hole on Raspberry Pi 4 (100.78.214.27)
  - Upstream: Unbound (recursive resolver, 127.0.0.1:5335 on the Pi)
  - No custom local domains configured yet
- **Fallback if Pi is down:** unknown — likely ISP default resolver
- **Public DNS records:** none currently (planned for future)
- **Note:** If a hostname fails to resolve and the Pi is unreachable, DNS is the likely cause

## Public Endpoints

- **AWS EC2:** Elastic IP (static), ports 80/443 via Nginx — MusicPlatform only
- **Cloudflare CDN:** music/audio media streaming for MusicPlatform (config in repo)
- **Cloudflare Worker:** content delivery layer in MusicPlatform repo
- **No reverse proxies, tunnels, or public domains** configured outside MusicPortfolio repo
