# supabase/ — VEXVortex backend

Managed Supabase backend: Postgres + RLS, Auth, REST/Data API, Edge Functions, Storage.

```text
supabase/
├── config.toml                       # Supabase CLI config for local dev
├── migrations/
│   ├── 20260101000000_vex_schema.sql # vex schema: teams, seasons, events, matches, rankings
│   └── 20260101000100_vex_rls.sql    # RLS: public read-only, no client writes
├── seed.sql                          # Fictional dev data (safe to commit)
└── functions/
    └── sync-events/index.ts          # service_role sync from RobotEvents API → vex.*
```

## Local dev

```bash
supabase start          # local Postgres + API + Studio
supabase db reset        # applies migrations/ then seed.sql
```

## Rules (see root `AGENTS.md`)

- RLS on every table in `vex`; `TO anon`/`TO authenticated`, never `auth.role()`.
- No insert/update/delete policies for `anon`/`authenticated` on any `vex.*` table — all writes go through `service_role` inside `functions/sync-events`, never the client.
- `functions/sync-events` requires the `x-sync-secret` header (`SYNC_SHARED_SECRET`) and reads `ROBOTEVENTS_TOKEN` — both are Supabase Edge Function secrets, never committed.
- Upstream VEX data (RobotEvents API) is fetched and validated server-side only; the iOS client only ever reads `vex.*` through PostgREST with the `anon` key.

## Not yet implemented

- Scheduling for `sync-events` (pg_cron or an external scheduler) — currently invoke-only.
- Aggregate views (season-long per-team trends, OPR/DPR-style stats) — `vex.rankings` currently stores only per-event rank/W-L-T as synced.
