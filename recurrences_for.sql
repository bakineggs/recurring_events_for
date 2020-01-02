CREATE OR REPLACE FUNCTION recurrences_for(
  event events,
  range_start TIMESTAMP,
  range_end  TIMESTAMP
)
  RETURNS SETOF DATE
  LANGUAGE plpgsql STABLE
  AS $BODY$
DECLARE
  recurrence event_recurrences;
  recurrences_start DATE := COALESCE(event.starts_at::date, event.starts_on);
  recurrences_end DATE := range_end;
  duration INTERVAL := interval_for(event.frequency) * event.separation;
  next_date DATE;
BEGIN
  IF event.until IS NOT NULL AND event.until < recurrences_end THEN
    recurrences_end := event.until;
  END IF;
  IF event.count IS NOT NULL AND recurrences_start + (event.count - 1) * duration < recurrences_end THEN
    recurrences_end := recurrences_start + (event.count - 1) * duration;
  END IF;

  FOR recurrence IN
    SELECT event_recurrences.*
      FROM (SELECT NULL) AS foo
      LEFT JOIN event_recurrences
        ON event_id = event.id
  LOOP
    FOR next_date IN
      SELECT *
        FROM generate_recurrences(
          event.frequency,
          duration,
          recurrences_start,
          COALESCE(event.ends_at::date, event.ends_on),
          range_start::date,
          recurrences_end,
          recurrence.month,
          recurrence.week,
          recurrence.day
        )
    LOOP
      RETURN NEXT next_date;
    END LOOP;
  END LOOP;
  RETURN;
END;
$BODY$;
