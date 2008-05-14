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
  recurrences_start DATE := CASE WHEN range_start + tz_offset < range_start THEN (range_start + tz_offset)::date ELSE range_start END;
  recurrences_end DATE := CASE WHEN range_end + tz_offset > range_end THEN (range_end + tz_offset)::date ELSE range_end END;
BEGIN
  FOR event IN
    SELECT *
      FROM events
      WHERE
        frequency <> 'once' OR
        (frequency = 'once' AND
          ((date <= (range_end + tz_offset)::date AND date >= (range_start + tz_offset)::date) OR
          (starts_at <= range_end AND ends_at >= range_start)))
  LOOP
    IF event.frequency = 'once' THEN
      RETURN NEXT event;
      CONTINUE;
    END IF;

    IF event.date IS NOT NULL THEN
      original_date := event.date;
      duration := '23:59:59'::interval;
    ELSE
      original_date := event.starts_at::date;
      start_time := event.starts_at::time;
      duration := event.ends_at - event.starts_at;
    END IF;

    IF event.count IS NOT NULL AND recurrences_start > original_date THEN
      recurrences_start := original_date;
    END IF;

    FOR next_date IN
      SELECT DISTINCT occurrence
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
      IF event.date IS NOT NULL THEN
        CONTINUE WHEN next_date < (range_start + tz_offset)::date OR next_date > (range_end + tz_offset)::date;
        event.date := next_date;
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
