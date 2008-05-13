CREATE OR REPLACE FUNCTION recurring_events_for(
  range_start TIMESTAMP,
  range_end  TIMESTAMP,
  tz_offset INTERVAL
)
  RETURNS SETOF events
  LANGUAGE plpgsql STABLE
  AS $BODY$
DECLARE
  row record;
  event events;
  cancelled INT;
  original_date DATE;
  start_date TIMESTAMP;
  start_time TIME;
  end_date TIMESTAMP;
  next_date DATE;
  recurrences_start TIMESTAMP;
  recurrences_end TIMESTAMP;
  duration INTERVAL;
BEGIN
  FOR row IN
    SELECT events.*, event_recurrences.day, event_recurrences.month, event_recurrences.week
      FROM events
      LEFT JOIN event_recurrences on event_recurrences.event_id = events.id
      WHERE
        frequency <> 'once' OR
        (frequency = 'once' AND
          ((date <= range_end::date AND date >= range_start::date) OR
          (starts_at + tz_offset <= range_end AND ends_at + tz_offset >= range_start)))
  LOOP
    event := row;

    IF event.frequency = 'once' THEN
      RETURN NEXT event;
      CONTINUE;
    END IF;

    IF event.date IS NOT NULL THEN
      start_date := event.date + interval '0 hours';
      end_date := event.date + interval '23:59:59';
    ELSE
      start_date := event.starts_at + tz_offset;
      end_date := event.ends_at + tz_offset;
    END IF;
    start_time := start_date::time;
    original_date := start_date::date;

    IF start_date <= range_end AND end_date >= range_start THEN
      SELECT COUNT(1) INTO cancelled
        FROM event_cancellations
        WHERE event_id = event.id
          AND date = start_date::date;
      IF cancelled = 0 THEN
        RETURN NEXT event;
      END IF;
    END IF;

    duration := interval_for(event.frequency);

    IF event.until IS NOT NULL AND event.until < range_end THEN
      recurrences_end := event.until;
    ELSIF event.count IS NOT NULL AND start_date + (event.count - 1) * duration < range_end THEN
      recurrences_end := start_date + (event.count - 1) * duration;
    ELSE
      recurrences_end := range_end;
    END IF;

    IF start_date > range_start THEN
      recurrences_start := start_date;
    ELSE
      recurrences_start := start_date + FLOOR(intervals_between(start_date::date, range_start::date, duration)) * duration;
    END IF;

    FOR next_date IN
      SELECT *
        FROM generate_recurrences(
          duration,
          recurrences_start::date,
          recurrences_end::date,
          row.month,
          row.week,
          row.day
        )
    LOOP
      CONTINUE WHEN next_date = original_date;
      SELECT COUNT(1) INTO cancelled
        FROM event_cancellations
        WHERE event_id = event.id
          AND date = next_date::date;
      CONTINUE WHEN cancelled > 0;
      IF event.date IS NOT NULL THEN
        event.date := next_date::date;
        CONTINUE WHEN event.date < range_start::date;
      ELSE
        event.starts_at := next_date + start_time - tz_offset;
        CONTINUE WHEN event.starts_at + tz_offset > range_end;
        event.ends_at := event.starts_at+(end_date-start_date);
        CONTINUE WHEN event.ends_at + tz_offset < range_start;
      END IF;
      RETURN NEXT event;
    END LOOP;
  END LOOP;
  RETURN;
END;
$BODY$;
