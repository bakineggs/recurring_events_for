CREATE OR REPLACE FUNCTION recurring_events_for(
  range_start TIMESTAMP,
  range_end  TIMESTAMP
)
  RETURNS SETOF events
  LANGUAGE plpgsql STABLE
  AS $BODY$
DECLARE
  row record;
  event events;
  cancellation event_cancellations;
  original_date DATE;
  start_date TIMESTAMP;
  start_time TEXT;
  end_date TIMESTAMP;
  next_date DATE;
  recurs TEXT;
  pattern_type TEXT;
  recurrences_end TIMESTAMP;
  offset INTERVAL;
  duration INTERVAL;
  recurrence_count INT;
BEGIN
  FOR row IN
    SELECT events.*, event_recurrences.day, event_recurrences.month, event_recurrences.week
      FROM events
      LEFT JOIN event_recurrences on event_recurrences.event_id = events.id
      WHERE
        frequency <> 'once' OR
        (frequency = 'once' AND
          ((date <= range_end::date AND date >= range_start::date) OR
          (starts_at <= range_end AND ends_at >= range_start)))
    LOOP
      event := row;

      <<recurrence>>
      FOR recurrence_count IN 1..1 LOOP
        IF event.frequency = 'once' OR
            (event.date <= range_end::date AND event.date >= range_start::date) OR
            (event.starts_at <= range_end AND event.ends_at >= range_start) THEN
          FOR cancellation IN
            SELECT *
              FROM event_cancellations
              WHERE event_id = event.id
                AND recurrence_id = 1
              LIMIT 1
          LOOP
            CONTINUE recurrence;
          END LOOP;
          event.recurrence_id := 1;
          RETURN NEXT event;
        END IF;
      END LOOP;

      CONTINUE WHEN event.frequency = 'once';

      IF event.date IS NOT NULL THEN
        start_date := event.date + interval '0 hours';
        end_date := event.date + interval '23:59:59';
      ELSE
        start_date := event.starts_at;
        end_date := event.ends_at;
      END IF;
      start_time := start_date::time::text;
      original_date := start_date::date;

      recurs := event.frequency;
      pattern_type := 'normal';
      offset := '00:00:00'::interval;
      IF recurs = 'weekly' AND row.day IS NOT NULL THEN
        offset := offset + (((row.day-cast(extract(dow from start_date) as int))%7)||' days')::interval;
      ELSIF recurs = 'monthly' AND row.week IS NOT NULL AND row.day IS NOT NULL THEN
        offset := offset + (((row.day-cast(extract(dow from start_date) as int))%7)||' days')::interval;
        IF extract(month from start_date+offset) < row.month OR (row.month = 1 AND extract(month from start_date+offset) = 12) THEN
          offset := offset + '7 days'::interval;
        ELSIF extract(month from start_date+offset) > row.month OR (row.month = 12 AND extract(month from start_date+offset) = 1) THEN
          offset := offset - '7 days'::interval;
        END IF;
        IF row.week > 0 THEN
          recurs := 'monthly_by_week_dow';
          pattern_type := 'positive_week_dow';
          offset := offset - '28 days'::interval;
          WHILE offset < 0 LOOP
            offset := offset + '28 days'::interval;
            WHILE CEIL(extract(day from start_date + offset)/7) > row.week LOOP
              offset := offset - '7 days'::interval;
            END LOOP;
            WHILE CEIL(extract(day from start_date + offset)/7) < row.week LOOP
              offset := offset + '7 days'::interval;
            END LOOP;
          END LOOP;
        ELSE
          recurs := 'monthly_by_week_dow';
          pattern_type := 'negative_week_dow';
          offset := offset - '28 days'::interval;
          WHILE offset < 0 LOOP
            offset := offset + '28 days'::interval;
            WHILE FLOOR((extract(day from start_date+offset+'1 month'::interval-(start_date+offset))-extract(day from start_date + offset))/7)-1 > row.week LOOP
              offset := offset + '7 days'::interval;
            END LOOP;
            WHILE FLOOR((extract(day from start_date+offset+'1 month'::interval-(start_date+offset))-extract(day from start_date + offset))/7)-1 < row.week LOOP
              offset := offset - '7 days'::interval;
            END LOOP;
          END LOOP;
        END IF;
      ELSIF recurs = 'monthly' AND row.day IS NOT NULL THEN
        offset := offset + ((row.day-cast(extract(day from start_date) as int))||' days')::interval;
      ELSIF recurs = 'yearly' AND row.week IS NOT NULL AND row.day IS NOT NULL THEN
        IF row.month IS NULL THEN
          row.month = extract(month from start_date);
        END IF;
        offset := offset + ((row.month-cast(extract(month from start_date) as int))||' months')::interval;
        offset := offset + (((row.day-cast(extract(dow from start_date+offset) as int))%7)||' days')::interval;
        IF extract(month from start_date+offset) < row.month OR (row.month = 1 AND extract(month from start_date+offset) = 12) THEN
          offset := offset + '7 days'::interval;
        ELSIF extract(month from start_date+offset) > row.month OR (row.month = 12 AND extract(month from start_date+offset) = 1) THEN
          offset := offset - '7 days'::interval;
        END IF;
        IF row.week > 0 THEN
          recurs := 'yearly_by_week_dow';
          pattern_type := 'positive_week_dow';
          offset := offset - '364 days'::interval;
          WHILE start_date+offset < start_date LOOP
            offset := offset + '364 days'::interval;
            IF extract(month from start_date+offset) != row.month THEN
              offset := offset + '7 days'::interval;
            END IF;
            WHILE CEIL(extract(day from start_date + offset)/7) > row.week LOOP
              offset := offset - '7 days'::interval;
            END LOOP;
            WHILE CEIL(extract(day from start_date + offset)/7) < row.week LOOP
              offset := offset + '7 days'::interval;
            END LOOP;
          END LOOP;
        ELSE
          recurs := 'yearly_by_week_dow';
          pattern_type := 'negative_week_dow';
          offset := offset - '364 days'::interval;
          WHILE start_date+offset < start_date LOOP
            offset := offset + '364 days'::interval;
            IF extract(month from start_date+offset) != row.month THEN
              offset := offset + '7 days'::interval;
            END IF;
            WHILE FLOOR((extract(day from start_date+offset+'1 month'::interval-(start_date+offset))-extract(day from start_date + offset))/7)-1 > row.week LOOP
              offset := offset + '7 days'::interval;
            END LOOP;
            WHILE FLOOR((extract(day from start_date+offset+'1 month'::interval-(start_date+offset))-extract(day from start_date + offset))/7)-1 < row.week LOOP
              offset := offset - '7 days'::interval;
            END LOOP;
          END LOOP;
        END IF;
      ELSIF recurs = 'yearly' AND row.month IS NOT NULL OR row.day IS NOT NULL THEN
        IF row.month IS NOT NULL THEN
          offset := offset + ((row.month-cast(extract(month from start_date) as int))||' months')::interval;
        END IF;
        IF row.day IS NOT NULL THEN
          offset := offset + ((row.day-cast(extract(day from start_date) as int))||' days')::interval;
        END IF;
      END IF;
      duration := interval_for(recurs);
      WHILE offset < 0 LOOP
        offset := offset + duration;
      END LOOP;
      start_date := start_date + offset;
      end_date := end_date + offset;

      IF event.until IS NOT NULL AND event.until < range_end THEN
        recurrences_end = event.until;
      ELSIF event.count IS NOT NULL AND start_date+(event.count-1)*duration < range_end THEN
        recurrences_end = start_date+(event.count-1)*duration;
      ELSE
        recurrences_end = range_end;
      END IF;

      recurrence_count := CEIL(intervals_between(start_date::date, range_start::date, duration));

      <<recurrences>>
      FOR next_date IN
        SELECT *
          FROM generate_recurrences(
            pattern_type,
            duration,
            start_date::date,
            range_start::date,
            recurrences_end::date
          )
      LOOP
        recurrence_count := recurrence_count + 1;
        CONTINUE WHEN next_date = original_date;
        EXIT WHEN event.count IS NOT NULL AND recurrence_count > event.count;
        FOR cancellation IN
          SELECT *
            FROM event_cancellations
            WHERE event_id = event.id
              AND recurrence_id = recurrence_count
            LIMIT 1
        LOOP
          CONTINUE recurrences;
        END LOOP;
        IF event.date IS NOT NULL THEN
          event.date := next_date;
        ELSE
          event.starts_at := (next_date || ' ' || start_time)::timestamp;
          event.ends_at := event.starts_at+(end_date-start_date);
          CONTINUE WHEN event.ends_at < range_start;
        END IF;
        event.recurrence_id = recurrence_count;
        RETURN NEXT event;
      END LOOP;
    END LOOP;
  RETURN;
END;
$BODY$;
