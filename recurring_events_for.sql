CREATE OR REPLACE FUNCTION recurring_events_for(
  range_start TIMESTAMP,
  range_end  TIMESTAMP,
  tz_offset INTERVAL,
  events_limit INT
)
  RETURNS SETOF events
  LANGUAGE plpgsql STABLE
  AS $BODY$
DECLARE
  event events;
  original_date DATE;
  start_time TIME;
  next_date DATE;
  duration INTERVAL;
BEGIN
  FOR event IN
    SELECT *
      FROM events
      WHERE
        frequency <> 'once' OR
        (frequency = 'once' AND
          ((date <= range_end::date AND date >= range_start::date) OR
          (starts_at + tz_offset <= range_end AND ends_at + tz_offset >= range_start)))
  LOOP
    IF event.frequency = 'once' THEN
      RETURN NEXT event;
      CONTINUE;
    END IF;

    IF event.date IS NOT NULL THEN
      original_date := event.date;
      start_time := '00:00:00'::time;
      duration := '23:59:59'::interval;
    ELSE
      original_date := (event.starts_at + tz_offset)::date;
      start_time := (event.starts_at + tz_offset)::time;
      duration := event.ends_at - event.starts_at;
    END IF;

    FOR next_date IN
      SELECT DISTINCT occurrence
        FROM (
          SELECT * FROM recurrences_for(event, range_start, range_end) AS occurrence
          UNION SELECT original_date
          LIMIT event.count
        ) AS occurrences
        WHERE
          occurrence <= range_end::date AND
          occurrence + duration >= range_start::date AND
          occurrence NOT IN (SELECT date FROM event_cancellations WHERE event_id = event.id)
        LIMIT events_limit
    LOOP
      IF event.date IS NOT NULL THEN
        event.date := next_date::date;
      ELSE
        event.starts_at := next_date + start_time - tz_offset;
        CONTINUE WHEN event.starts_at + tz_offset > range_end;
        event.ends_at := event.starts_at + duration;
        CONTINUE WHEN event.ends_at + tz_offset < range_start;
      END IF;
      RETURN NEXT event;
    END LOOP;
  END LOOP;
  RETURN;
END;
$BODY$;
