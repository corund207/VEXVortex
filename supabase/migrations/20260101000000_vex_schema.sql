-- VEXVortex core schema: teams, seasons, events, matches, rankings.
-- Domain tables live in `vex`, not `public` (see root AGENTS.md).

create schema if not exists vex;

create extension if not exists pgcrypto with schema extensions;

-- ---------------------------------------------------------------------------
-- Teams
-- ---------------------------------------------------------------------------
create table vex.teams (
  id uuid primary key default gen_random_uuid(),
  number text not null unique,               -- e.g. '90000A'
  name text not null,
  organization text,
  city text,
  region text,
  country text,
  program text not null default 'VRC',       -- VRC, VEXU, VIQRC, etc.
  grade_level text,
  robot_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table vex.teams is 'VEX team directory, synced read-mostly from upstream event data.';

-- ---------------------------------------------------------------------------
-- Seasons
-- ---------------------------------------------------------------------------
create table vex.seasons (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,                 -- e.g. 'Push Back 2025-2026'
  program text not null default 'VRC',
  start_date date,
  end_date date,
  is_current boolean not null default false,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------------------
create table vex.events (
  id uuid primary key default gen_random_uuid(),
  season_id uuid references vex.seasons (id) on delete set null,
  event_code text unique,                    -- upstream event identifier
  name text not null,
  event_type text,                           -- e.g. 'tournament', 'scrimmage'
  start_date date not null,
  end_date date not null,
  city text,
  region text,
  country text,
  venue text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index events_season_id_idx on vex.events (season_id);
create index events_start_date_idx on vex.events (start_date desc);

-- ---------------------------------------------------------------------------
-- Event <-> team registration
-- ---------------------------------------------------------------------------
create table vex.event_teams (
  event_id uuid not null references vex.events (id) on delete cascade,
  team_id uuid not null references vex.teams (id) on delete cascade,
  division text,
  primary key (event_id, team_id)
);

create index event_teams_team_id_idx on vex.event_teams (team_id);

-- ---------------------------------------------------------------------------
-- Matches
-- ---------------------------------------------------------------------------
create table vex.matches (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references vex.events (id) on delete cascade,
  division text,
  round text,                                -- 'qualification', 'elimination', ...
  match_number int not null,
  scheduled_at timestamptz,
  red1_team_id uuid references vex.teams (id),
  red2_team_id uuid references vex.teams (id),
  blue1_team_id uuid references vex.teams (id),
  blue2_team_id uuid references vex.teams (id),
  red_score int,
  blue_score int,
  status text not null default 'scheduled'
    check (status in ('scheduled', 'in_progress', 'final')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index matches_event_id_idx on vex.matches (event_id);
create index matches_scheduled_at_idx on vex.matches (scheduled_at);

-- ---------------------------------------------------------------------------
-- Rankings (one row per team per event)
-- ---------------------------------------------------------------------------
create table vex.rankings (
  event_id uuid not null references vex.events (id) on delete cascade,
  team_id uuid not null references vex.teams (id) on delete cascade,
  rank int not null,
  wins int not null default 0,
  losses int not null default 0,
  ties int not null default 0,
  wp int not null default 0,                 -- win points
  ap int not null default 0,                 -- autonomous points
  sp int not null default 0,                 -- strength of schedule points
  average_points numeric,
  updated_at timestamptz not null default now(),
  primary key (event_id, team_id)
);

create index rankings_event_id_rank_idx on vex.rankings (event_id, rank);

-- ---------------------------------------------------------------------------
-- updated_at maintenance
-- ---------------------------------------------------------------------------
create or replace function vex.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger teams_set_updated_at before update on vex.teams
  for each row execute function vex.set_updated_at();

create trigger events_set_updated_at before update on vex.events
  for each row execute function vex.set_updated_at();

create trigger matches_set_updated_at before update on vex.matches
  for each row execute function vex.set_updated_at();

create trigger rankings_set_updated_at before update on vex.rankings
  for each row execute function vex.set_updated_at();
