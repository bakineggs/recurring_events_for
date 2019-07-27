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
  original_date_in_zone DATE;
  start_time TIME;
  start_time_in_zone TIME;
  next_date DATE;
  next_time_in_zone TIME;
  duration INTERVAL;
  time_offset INTERVAL;
  recurrences_start DATE := CASE WHEN (timezone('UTC', range_start) AT TIME ZONE time_zone) < range_start THEN (timezone('UTC', range_start) AT TIME ZONE time_zone)::date ELSE range_start END;
  recurrences_end DATE := CASE WHEN (timezone('UTC', range_end) AT TIME ZONE time_zone) > range_end THEN (timezone('UTC', range_end) AT TIME ZONE time_zone)::date ELSE range_end END;
BEGIN
  FOR event IN
    SELECT *
      FROM events
      WHERE
        frequency <> 'once' OR
        (frequency = 'once' AND
          ((starts_on IS NOT NULL AND ends_on IS NOT NULL AND starts_on <= (timezone('UTC', range_end) AT TIME ZONE time_zone)::date AND ends_on >= (timezone('UTC', range_start) AT TIME ZONE time_zone)::date) OR
           (starts_on IS NOT NULL AND starts_on <= (timezone('UTC', range_end) AT TIME ZONE time_zone)::date AND starts_on >= (timezone('UTC', range_start) AT TIME ZONE time_zone)::date) OR
           (starts_at <= range_end AND ends_at >= range_start)))
  LOOP
    IF event.frequency = 'once' THEN
      RETURN NEXT event;
      CONTINUE;
    END IF;

    -- All-day event
    IF event.starts_on IS NOT NULL AND event.ends_on IS NULL THEN
      original_date := event.starts_on;
      duration := '1 day'::interval;
    -- Multi-day event
    ELSIF event.starts_on IS NOT NULL AND event.ends_on IS NOT NULL THEN
      original_date := event.starts_on;
      duration := timezone(time_zone, event.ends_on) - timezone(time_zone, event.starts_on);
    -- Timespan event
    ELSE
      original_date := event.starts_at::date;
      original_date_in_zone := (timezone('UTC', event.starts_at) AT TIME ZONE event.timezone_name)::date;
      start_time := event.starts_at::time;
      start_time_in_zone := (timezone('UTC', event.starts_at) AT time ZONE event.timezone_name)::time;
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
          ORDER BY occurrence
          LIMIT event.count
        ) AS occurrences
        WHERE
          occurrence::date <= recurrences_end AND
          (occurrence + duration)::date >= recurrences_start AND
          occurrence NOT IN (SELECT date FROM event_cancellations WHERE event_id = event.id)
        LIMIT events_limit
    LOOP
      -- All-day event
      IF event.starts_on IS NOT NULL AND event.ends_on IS NULL THEN
        CONTINUE WHEN next_date < (timezone('UTC', range_start) AT TIME ZONE time_zone)::date OR next_date > (timezone('UTC', range_end) AT TIME ZONE time_zone)::date;
        event.starts_on := next_date;

      -- Multi-day event
      ELSIF event.starts_on IS NOT NULL AND event.ends_on IS NOT NULL THEN
        event.starts_on := next_date;
        CONTINUE WHEN event.starts_on > (timezone('UTC', range_end) AT TIME ZONE time_zone)::date;
        event.ends_on := next_date + duration;
        CONTINUE WHEN event.ends_on < (timezone('UTC', range_start) AT TIME ZONE time_zone)::date;

      -- Timespan event
      ELSE
        next_time_in_zone := (timezone('UTC', (next_date + start_time)) at time zone event.timezone_name)::time;
        time_offset := (original_date_in_zone + next_time_in_zone) - (original_date_in_zone + start_time_in_zone);
        event.starts_at := next_date + start_time - time_offset;

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
