# Filesystems & storage decisions

Per-host storage layout and the architectural reasons behind partition / mount-root choices. Use when evaluating where to put caches, data dirs, big build trees, or anything else that grows.

## debian-macbook (always-on agent host, dual-boot Debian + macOS)

Single internal SSD, GPT, dual-boot:

| Partition | FS    | Size  | Mount         | Purpose |
|---|---|---|---|---|
| sda1 | vfat  | 162 M | `/boot/efi`   | shared EFI |
| sda2 | APFS  | —     | (macOS)       | the macOS side; **don't touch from Debian** |
| sda3 | ext4  | 55 G  | `/`           | Debian root — keep small, rebootable |
| sda4 | swap  | 11 G  | swap          | |
| sda5 | ext4  | 289 G | `/srv`        | data partition (272 G free) |

**Rule of thumb on this host:** anything that grows or caches goes on `/srv`. `/` stays small so a runaway cache can never wedge boot.

### Active layout under `/srv`

- `/srv/repos/` — git checkouts (e.g. `music-platform`)
- `/srv/tools/` — long-lived tools (e.g. `ephemeral-runners`)
- `/srv/runner-cache/pnpm-store/` — shared content-addressable pnpm store, bind-mounted into every runner container (UID 1001)
- **planned:** `/srv/docker-data/` as Docker's `data-root`. Migration script: `/srv/tools/ephemeral-runners/scripts/migrate-docker-data-root.sh`.

### Why move Docker's data-root to /srv

Two reasons that compound:

1. **Room.** Default `/var/lib/docker` is on `/` (sda3, 26 G free). One pulled image set + a few in-flight DinD overlays can fill that and brick the host. `/srv` has 272 G.
2. **pnpm hardlink fast path.** pnpm hardlinks from its store into `node_modules`. Hardlinks are same-FS-only. Today the store sits on sda5 but containers' working trees sit on sda3 — pnpm falls back to copy mode. Putting both on sda5 unlocks ~5–10× faster `node_modules` materialization.

### What NOT to do

- **Don't repartition.** Dual-boot with APFS + EFI is fragile to touch from Debian; we already have the partitions we need.
- **Don't put caches on `/`.** Even with prune timers, the failure mode is host-down, not job-down.
- **Don't assume systemd unit limits cover Docker containers.** Containers spawned by `docker run` live under `system.slice/docker.service`'s cgroup, not the unit's tree. Use per-container `--cpus`/`--memory` flags on `docker run` instead.

## Other hosts

Not yet documented here. Pi, Oracle, AWS each have their own constraints (small SD card, free-tier disk, Elastic-volume attached). Add sections as decisions land.
