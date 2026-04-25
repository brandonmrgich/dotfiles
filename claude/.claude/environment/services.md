# Services

## Pi-hole

- **Host:** Raspberry Pi 4 (DietPi)
- **Purpose:** Network-wide DNS-based ad and tracker filtering
- **Access:** http://100.78.214.27/admin (Pi-hole web UI via Tailscale IP)
- **Management:** apt (DietPi package)
- **Note:** MVP configuration — early stage, room for improvement

## Unbound

- **Host:** Raspberry Pi 4 (DietPi)
- **Purpose:** Recursive DNS resolver; upstream for Pi-hole
- **Access:** Internal only — 127.0.0.1:5335 on the Pi
- **Management:** apt (DietPi package)
- **Note:** Not directly interacted with; managed as Pi-hole's upstream

## Nginx (MusicPlatform)

- **Host:** AWS EC2
- **Purpose:** Reverse proxy and TLS termination for MusicPlatform API
- **Access:** Elastic IP, ports 80 (redirect) and 443
- **Management:** Docker Compose (`infra/docker/docker-compose.prod.yml`)
- **Config:** `infra/docker/nginx/templates/api.conf.template` in MusicPortfolio repo

## Fastify API (MusicPlatform)

- **Host:** AWS EC2
- **Purpose:** MusicPlatform backend — artists, recordings, releases, media intake
- **Access:** Port 4000 internal; exposed via Nginx on 443
- **Management:** Docker Compose (`infra/docker/docker-compose.prod.yml`)
- **Health check:** GET /health/ready
- **Repo:** ~/Development/GitHubProjects/MusicPortfolio

## PostgreSQL 16 (MusicPlatform)

- **Host:** AWS EC2
- **Purpose:** MusicPlatform primary database
- **Access:** Internal only (Docker bridge network)
- **Management:** Docker Compose (`infra/docker/docker-compose.prod.yml`)

## Cloudflare CDN

- **Host:** Edge (Cloudflare-managed)
- **Purpose:** Music and audio media streaming for MusicPlatform
- **Access:** CDN URLs — see MusicPortfolio repo for config
- **Management:** Cloudflare dashboard + Cloudflare Worker in MusicPortfolio repo
