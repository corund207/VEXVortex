# Documentation Agent Instructions

`docs/` holds operator- and user-facing documentation for VEXVortex, the VEX Robotics stats iOS app (Supabase backend, Codemagic pipeline). See root `AGENTS.md` for project-wide rules.

- Document user-facing app behavior (screens, offline/stale-data indicators, favorites), setup prerequisites (Supabase project, Xcode, Codemagic), exact commands, expected output, and known limitations.
- Cover App Store–facing material as it's produced: privacy policy, App Store metadata/screenshots, support contact.
- Never include real secrets, tokens, private keys, or personal identifiers — same rule as everywhere else in this repo.
- Label anything destructive (schema resets, key rotation) clearly and give a rollback path.
- Keep docs honest about implementation status: don't describe a feature as shipped if it's still on the `README.md` roadmap.
