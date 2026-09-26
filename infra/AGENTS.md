# Infrastructure Agent Instructions

> ⚠️ **LEGACY — not part of VEXVortex (the VEX stats app).** This describes a pre-rebrand, self-hosted homelab appliance (Docker Compose, systemd, Tailscale) that predates the pivot to the VEX Robotics stats app in `README.md`. VEXVortex's actual backend is *managed* Supabase — no host/container infra to run. Kept temporarily pending move to a separate self-host repo. Do not apply these instructions to VEXVortex work — use root `AGENTS.md` instead.

Infrastructure changes must be declarative, version-pinned, idempotent, and reviewable. Default to no public listeners except the explicitly documented HTTPS application endpoint. Validate Docker Compose, systemd units, firewall rules, Tailscale policy, backup mounts, and health checks before applying changes. Never place secrets in tracked files; provide `.env.example` and a secure secret-generation/bootstrap flow.
