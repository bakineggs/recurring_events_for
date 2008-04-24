CREATE OR REPLACE FUNCTION recurring_events_for(
  for_user_id INTEGER,
  range_start TIMESTAMP,
  range_end   TIMESTAMP
)
  RETURNS SETOF events
  LANGUAGE plpgsql STABLE
  AS $BODY$
DECLARE
  event events;
  start_date TIMESTAMPTZ;
  start_time TEXT;
  ends_at    TIMESTAMPTZ;
  next_date  DATE;
  recurs_at  TIMESTAMPTZ;
BEGIN
  FOR event IN 
    SELECT *
      FROM events
      WHERE user_id = for_user_id
        AND (
          recurrence <> 'none'
          OR  (
            recurrence = 'none'
            AND starts_at BETWEEN range_start AND range_end
          )
        )
    LOOP
      IF event.recurrence = 'none' THEN
        RETURN NEXT event;
        CONTINUE;
      END IF;

      start_date := event.starts_at::timestamptz AT TIME ZONE event.start_tz;
      start_time := start_date::time::text;
      ends_at    := event.ends_at::timestamptz AT TIME ZONE event.end_tz;

      FOR next_date IN
        SELECT *
          FROM generate_recurrences(
            event.recurrence,
            start_date::date,
            (range_end AT TIME ZONE event.start_tz)::date
          )
      LOOP
        recurs_at := (next_date || ' ' || start_time)::timestamp
          AT TIME ZONE event.start_tz;
        EXIT WHEN recurs_at > range_end;
        CONTINUE WHEN recurs_at < range_start AND ends_at < range_start;
        event.starts_at := recurs_at;
        event.ends_at   := ends_at;
        RETURN NEXT event;
      END LOOP;
    END LOOP;
  RETURN;
END;
$BODY$;
