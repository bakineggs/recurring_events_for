CREATE OR REPLACE FUNCTION recurring_events_for(
  range_start TIMESTAMP,
  range_end  TIMESTAMP,
  time_zone CHARACTER VARYING,
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
  recurrences_start DATE := CASE WHEN (timezone('UTC', range_start) AT TIME ZONE time_zone) < range_start THEN (timezone('UTC', range_start) AT TIME ZONE time_zone)::date ELSE range_start END;
  recurrences_end DATE := CASE WHEN (timezone('UTC', range_end) AT TIME ZONE time_zone) > range_end THEN (timezone('UTC', range_end) AT TIME ZONE time_zone)::date ELSE range_end END;
BEGIN
  FOR event IN
    SELECT *
      FROM events
      WHERE
        frequency <> 'once' OR
        (frequency = 'once' AND
          ((start_date IS NOT NULL AND end_date IS NOT NULL AND start_date <= (timezone('UTC', range_end) AT TIME ZONE time_zone)::date AND end_date >= (timezone('UTC', range_start) AT TIME ZONE time_zone)::date) OR
           (start_date IS NOT NULL AND start_date <= (timezone('UTC', range_end) AT TIME ZONE time_zone)::date AND start_date >= (timezone('UTC', range_start) AT TIME ZONE time_zone)::date) OR
           (starts_at <= range_end AND ends_at >= range_start)))
  LOOP
    IF event.frequency = 'once' THEN
      RETURN NEXT event;
      CONTINUE;
    END IF;

    -- All-day event
    IF event.start_date IS NOT NULL AND event.end_date IS NULL THEN
      original_date := event.start_date;
      duration := '1 day'::interval;
    -- Multi-day event
    ELSIF event.start_date IS NOT NULL AND event.end_date IS NOT NULL THEN
      original_date := event.start_date;
      duration := timezone('UTC', event.end_date) - timezone('UTC', event.start_date);
    -- Timespan event
    ELSE
      original_date := event.starts_at::date;
      start_time := event.starts_at::time;
      duration := event.ends_at - event.starts_at;
    END IF;

    IF event.count IS NOT NULL THEN
      recurrences_start := original_date;
    END IF;

    FOR next_date IN
      SELECT occurrence
        FROM (
          SELECT * FROM recurrences_for(event, recurrences_start, recurrences_end) AS occurrence
          UNION SELECT original_date
          LIMIT event.count
        ) AS occurrences
        WHERE
          occurrence::date <= recurrences_end AND
          (occurrence + duration)::date >= recurrences_start AND
          occurrence NOT IN (SELECT date FROM event_cancellations WHERE event_id = event.id)
        LIMIT events_limit
    LOOP
      -- All-day event
      IF event.start_date IS NOT NULL AND event.end_date IS NULL THEN
        CONTINUE WHEN next_date < (timezone('UTC', range_start) AT TIME ZONE time_zone)::date OR next_date > (timezone('UTC', range_end) AT TIME ZONE time_zone)::date;
        event.start_date := next_date;

      -- Multi-day event
      ELSIF event.start_date IS NOT NULL AND event.end_date IS NOT NULL THEN
        event.start_date := next_date;
        CONTINUE WHEN event.start_date > (timezone('UTC', range_end) AT TIME ZONE time_zone)::date;
        event.end_date := next_date + duration;
        CONTINUE WHEN event.end_date < (timezone('UTC', range_start) AT TIME ZONE time_zone)::date;

      -- Timespan event
      ELSE
        event.starts_at := next_date + start_time;
        CONTINUE WHEN event.starts_at > range_end;
        event.ends_at := event.starts_at + duration;
        CONTINUE WHEN event.ends_at < range_start;
      END IF;

      RETURN NEXT event;
    END LOOP;
  END LOOP;
  RETURN;
END;
$BODY$;
