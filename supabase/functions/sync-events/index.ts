// supabase/functions/sync-events/index.ts
//
// Server-side sync: pulls teams/events/rankings for one upstream event from
// the RobotEvents API (https://www.robotevents.com/api/v2) and upserts them
// into `vex.*`. Runs with service_role — never ships to the iOS client.
//
// Required Edge Function secrets (set via `supabase secrets set`, never in git):
//   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY  — injected automatically by Supabase
//   ROBOTEVENTS_TOKEN                        — RobotEvents API bearer token
//   SYNC_SHARED_SECRET                       — required `x-sync-secret` header value
//
// Invoke from a scheduled job (pg_cron / Codemagic cron / external scheduler),
// never expose this function's URL publicly without the shared-secret check.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const ROBOTEVENTS_BASE = 'https://www.robotevents.com/api/v2';

interface SyncRequest {
  robotEventsEventId: number;
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return json({ error: 'method not allowed' }, 405);
  }

  const expectedSecret = Deno.env.get('SYNC_SHARED_SECRET');
  const providedSecret = req.headers.get('x-sync-secret');
  if (!expectedSecret || providedSecret !== expectedSecret) {
    return json({ error: 'unauthorized' }, 401);
  }

  let body: SyncRequest;
  try {
    body = await req.json();
  } catch {
    return json({ error: 'invalid JSON body' }, 400);
  }

  if (!body.robotEventsEventId || typeof body.robotEventsEventId !== 'number') {
    return json({ error: 'robotEventsEventId (number) is required' }, 400);
  }

  const robotEventsToken = Deno.env.get('ROBOTEVENTS_TOKEN');
  if (!robotEventsToken) {
    return json({ error: 'server misconfigured: ROBOTEVENTS_TOKEN not set' }, 500);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!supabaseUrl || !serviceRoleKey) {
    return json({ error: 'server misconfigured: Supabase service credentials not set' }, 500);
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });

  try {
    const event = await fetchRobotEvent(body.robotEventsEventId, robotEventsToken);
    const teams = await fetchRobotEventTeams(body.robotEventsEventId, robotEventsToken);

    const { data: eventRow, error: eventError } = await supabase
      .schema('vex')
      .from('events')
      .upsert(
        {
          event_code: event.sku,
          name: event.name,
          event_type: event.event_type ?? null,
          start_date: event.start,
          end_date: event.end,
          city: event.location?.city ?? null,
          region: event.location?.region ?? null,
          country: event.location?.country ?? null,
          venue: event.location?.venue ?? null,
        },
        { onConflict: 'event_code' },
      )
      .select('id')
      .single();

    if (eventError) throw eventError;

    for (const team of teams) {
      const { data: teamRow, error: teamError } = await supabase
        .schema('vex')
        .from('teams')
        .upsert(
          {
            number: team.number,
            name: team.team_name,
            organization: team.organization ?? null,
            city: team.location?.city ?? null,
            region: team.location?.region ?? null,
            country: team.location?.country ?? null,
            program: team.program?.code ?? 'VRC',
            grade_level: team.grade ?? null,
            robot_name: team.robot_name ?? null,
          },
          { onConflict: 'number' },
        )
        .select('id')
        .single();

      if (teamError) throw teamError;

      const { error: linkError } = await supabase
        .schema('vex')
        .from('event_teams')
        .upsert(
          { event_id: eventRow.id, team_id: teamRow.id },
          { onConflict: 'event_id,team_id' },
        );

      if (linkError) throw linkError;
    }

    return json({ ok: true, eventId: eventRow.id, teamsSynced: teams.length });
  } catch (err) {
    console.error('sync-events failed', err);
    return json({ error: 'sync failed', detail: String(err) }, 502);
  }
});

async function fetchRobotEvent(id: number, token: string) {
  const res = await fetch(`${ROBOTEVENTS_BASE}/events/${id}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!res.ok) throw new Error(`RobotEvents /events/${id} → ${res.status}`);
  return res.json();
}

async function fetchRobotEventTeams(id: number, token: string) {
  const res = await fetch(`${ROBOTEVENTS_BASE}/events/${id}/teams?per_page=250`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!res.ok) throw new Error(`RobotEvents /events/${id}/teams → ${res.status}`);
  const body = await res.json();
  return body.data ?? [];
}

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { 'content-type': 'application/json' },
  });
}
