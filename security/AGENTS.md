# Security Agent Instructions

> ⚠️ **LEGACY — not part of VEXVortex (the VEX stats app).** This describes a security-audit scope for a pre-rebrand, self-hosted homelab appliance ("VEXVortex host, its containers") that predates the pivot to the VEX Robotics stats app in `README.md`. For current security scope and rules (Supabase RLS, iOS client, Codemagic secrets), see root `SECURITY.md` and root `AGENTS.md`. Kept temporarily pending move to a separate self-host repo.

Perform authorized, non-destructive assessment only against the VEXVortex host, its containers, and explicitly listed public endpoints. Do not scan the broader LAN, exploit destructive payloads, stress-test services, dump secrets, or alter data. Report evidence, severity, exploit preconditions, remediation, residual risk, and a safe verification command for every finding.
