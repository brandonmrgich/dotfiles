---
name: "[HomebrewSkill] environment-map"
description: >
  User's broader environment map — hosts, networks, services, and major repos
  beyond the current working directory. Activate when prompts mention: specific
  hosts (m1-macbook, debian-macbook, macbook-intel-2012-debian, DietPi, pi,
  instance-20230401-new, ip-172-31-91-143, oracle, aws); specific services
  (pihole, pi-hole, unbound, Gastown, Nginx, Fastify); networking concepts
  (Tailscale, tail2c0e11.ts.net, MagicDNS, tailnet, pihole DNS, 100.78.214.27);
  repos by name (DubSync, ContentAutomator, ContentAutomatorWeb, MusicPortfolio,
  MusicPlatform); or when asked "where does X live", "how do I reach Y",
  "what runs on Z", or about cross-machine workflows. Do NOT activate for
  routine work scoped entirely to one repo — project-local CLAUDE.md handles
  that.
---

# Environment Map

Specific details live in `~/.claude/environment/`. Read the relevant file
when the question requires depth:

- `~/.claude/environment/hosts.md` — machine details, how to reach each
- `~/.claude/environment/networks.md` — Tailscale, LAN, DNS
- `~/.claude/environment/services.md` — what runs where
- `~/.claude/environment/repos.md` — major repo inventory

## Routing rules

- "How do I SSH into X?" → read hosts.md, find X
- "What's the Tailscale name for Y?" → read hosts.md or networks.md
- "Where does service Z run?" → read services.md
- "Where is repo W?" → read repos.md
- "How do I deploy from M1 to AWS?" → read hosts.md + services.md + MusicPortfolio CLAUDE.md

## Always-on rules

1. Tailscale-enrolled hosts (m1-macbook, debian-macbook, pi) are reachable
   from anywhere — don't assume LAN-only.
2. The Pi 4 is the network DNS primary. If a hostname won't resolve and the
   Pi is unreachable, that's the likely cause.
3. AWS EC2 and Oracle Cloud are public-IP only — not on Tailscale.
4. All hosts have `~/.ssh/config` entries — SSH access is always `ssh <alias>`.
5. Each major repo may have its own CLAUDE.md. When working inside one,
   that repo's context is authoritative.
6. The files in `~/.claude/environment/` are durable references — propose
   updates when something contradict them.

## What you must never do

- Do not invent host details, IPs, or service URLs — read from the environment files.
- Do not assume LAN-only access when Tailscale is configured.
- Do not load this skill's referenced files if the question is scoped entirely
  to a single repo's internals — defer to that repo's CLAUDE.md.
