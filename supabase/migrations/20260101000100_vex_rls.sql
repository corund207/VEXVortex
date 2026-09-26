-- RLS for every table in `vex`. All are public read-only stats: anyone
-- (anon or authenticated) can select; there are NO client insert/update/delete
-- policies anywhere in this file. Writes happen only via service_role inside
-- Edge Functions / scheduled sync jobs, which bypasses RLS by design — never
-- give the anon/authenticated roles write grants on these tables.

alter table vex.teams enable row level security;
alter table vex.seasons enable row level security;
alter table vex.events enable row level security;
alter table vex.event_teams enable row level security;
alter table vex.matches enable row level security;
alter table vex.rankings enable row level security;

create policy "teams_select_public" on vex.teams
  for select to anon, authenticated using (true);

create policy "seasons_select_public" on vex.seasons
  for select to anon, authenticated using (true);

create policy "events_select_public" on vex.events
  for select to anon, authenticated using (true);

create policy "event_teams_select_public" on vex.event_teams
  for select to anon, authenticated using (true);

create policy "matches_select_public" on vex.matches
  for select to anon, authenticated using (true);

create policy "rankings_select_public" on vex.rankings
  for select to anon, authenticated using (true);

-- Explicit least-privilege grants (RLS still applies on top of these).
-- No insert/update/delete grants for anon/authenticated on any vex.* table.
grant usage on schema vex to anon, authenticated;
grant select on
  vex.teams,
  vex.seasons,
  vex.events,
  vex.event_teams,
  vex.matches,
  vex.rankings
to anon, authenticated;
