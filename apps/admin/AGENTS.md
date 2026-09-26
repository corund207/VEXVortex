# Admin App Agent Instructions

> ⚠️ **LEGACY — not part of VEXVortex (the VEX stats app).** This describes a pre-rebrand, self-hosted Tailscale homelab admin app that predates the pivot to the VEX Robotics stats app in `README.md`. Kept temporarily pending move to a separate self-host repo (see root `README.md` § Repository Map). Do not apply these instructions to VEXVortex iOS/Supabase work — use root `AGENTS.md` instead.

The admin app is a private control plane, not a public product. It must bind only to localhost or the Tailscale interface and require Tailscale identity plus application authorization. Do not implement a browser terminal; terminal access remains SSH-only. All mutations need explicit confirmation, audit events, CSRF protection where applicable, strict input validation, and least-privilege service boundaries.
