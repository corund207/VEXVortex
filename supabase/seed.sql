-- Dev seed data — fictional teams/events for local `supabase start` only.
-- No real secrets, no scraped upstream data. Safe to commit.

insert into vex.seasons (name, program, start_date, end_date, is_current) values
  ('Push Back 2025-2026', 'VRC', '2025-05-01', '2026-04-30', true);

insert into vex.teams (number, name, organization, city, region, country, program, robot_name) values
  ('90000A', 'Vortex Robotics', 'Example Middle School', 'Springfield', 'CA', 'USA', 'VRC', 'Maelstrom'),
  ('90000B', 'Vortex Robotics B', 'Example Middle School', 'Springfield', 'CA', 'USA', 'VRC', 'Squall'),
  ('12345X', 'Iron Falcons', 'Example High School', 'Riverside', 'CA', 'USA', 'VRC', 'Talon'),
  ('54321Y', 'Circuit Breakers', 'Example STEM Academy', 'Lakeside', 'TX', 'USA', 'VRC', 'Overcurrent');

insert into vex.events (season_id, event_code, name, event_type, start_date, end_date, city, region, country, venue)
select s.id, 'RE-VRC-25-0001', 'Springfield Regional Championship', 'tournament', '2026-01-10', '2026-01-10',
       'Springfield', 'CA', 'USA', 'Springfield Community College Gym'
from vex.seasons s where s.name = 'Push Back 2025-2026';

insert into vex.event_teams (event_id, team_id, division)
select e.id, t.id, 'Division A'
from vex.events e, vex.teams t
where e.event_code = 'RE-VRC-25-0001';

insert into vex.matches (event_id, division, round, match_number, scheduled_at,
                          red1_team_id, red2_team_id, blue1_team_id, blue2_team_id,
                          red_score, blue_score, status)
select e.id, 'Division A', 'qualification', 1, e.start_date::timestamptz + interval '9 hours',
       t1.id, t2.id, t3.id, t4.id, 87, 64, 'final'
from vex.events e,
     vex.teams t1, vex.teams t2, vex.teams t3, vex.teams t4
where e.event_code = 'RE-VRC-25-0001'
  and t1.number = '90000A' and t2.number = '12345X'
  and t3.number = '90000B' and t4.number = '54321Y';

insert into vex.rankings (event_id, team_id, rank, wins, losses, ties, wp, ap, sp, average_points)
select e.id, t.id, row_number() over (order by t.number), 1, 0, 0, 6, 4, 12, 87.0
from vex.events e, vex.teams t
where e.event_code = 'RE-VRC-25-0001';
