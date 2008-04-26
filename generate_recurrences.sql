CREATE OR REPLACE FUNCTION  generate_recurrences(
  pattern_type TEXT,
  duration INTERVAL,
  original_date DATE,
  range_start DATE,
  range_end DATE
)
  RETURNS setof DATE
  LANGUAGE plpgsql IMMUTABLE
  AS $BODY$
DECLARE
  next_date DATE;
BEGIN
  next_date := original_date + duration * CEIL(intervals_between(original_date, range_start, duration));
  IF pattern_type = 'positive_week_dow' OR pattern_type = 'negative_week_dow' THEN
    -- in case the first recurrence is before next_date but after range_start
    next_date := next_date - 2 * duration;
    LOOP
      -- prevent an infinite loop
      IF duration = '28 days'::interval AND extract(month from next_date + duration) = extract(month from next_date) THEN
        next_date := next_date + duration;
      END IF;
      next_date := next_date + duration;

      -- ensure month is correct for yearly events
      IF duration = '364 days'::interval THEN
        WHILE extract(month from next_date) != extract(month from original_date) LOOP
          next_date := next_date + cast(extract(month from original_date) - extract(month from next_date) as int) % 12 * '28 days'::interval;
        END LOOP;
      END IF;

      IF pattern_type = 'positive_week_dow' THEN
        next_date := next_date
          + (CEIL(extract(day from original_date) / 7)
            - CEIL(extract(day from next_date) / 7))
          * '7 days'::interval;
      ELSE
        next_date := next_date
          + (CEIL((extract(day from next_date + '1 month'::interval - next_date) - extract(day from next_date)) / 7)
            - CEIL((extract(day from original_date + '1 month'::interval - original_date) - extract(day from original_date)) / 7))
          * '7 days'::interval;
      END IF;
      EXIT WHEN next_date > range_end;
      CONTINUE WHEN next_date < range_start OR next_date < original_date; -- subtracting an extra duration could have put us before the range_start or original_date
      RETURN NEXT next_date;
    END LOOP;
  ELSE
    WHILE next_date <= range_end LOOP
      RETURN NEXT next_date;
      next_date := next_date + duration;
    END LOOP;
  END IF;
END;
$BODY$;
