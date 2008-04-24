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
    WHILE next_date <= range_end LOOP
      RETURN NEXT next_date;
      next_date := next_date + duration;
      WHILE duration != '28 days'::interval AND extract(month from next_date) != extract(month from original_date) LOOP
        next_date := next_date + '28 days'::interval;
      END LOOP;
      IF pattern_type = 'positive_week_dow' THEN
        WHILE CEIL(extract(day from next_date)/7) > CEIL(extract(day from original_date)/7) LOOP
          next_date := next_date - '7 days'::interval;
        END LOOP;
        WHILE CEIL(extract(day from next_date)/7) < CEIL(extract(day from original_date)/7) LOOP
          next_date := next_date + '7 days'::interval;
        END LOOP;
      ELSE
        WHILE FLOOR((extract(day from next_date+'1 month'::interval-next_date)-extract(day from next_date))/7) > FLOOR((extract(day from original_date+'1 month'::interval-original_date)-extract(day from original_date))/7) LOOP
          next_date := next_date + '7 days'::interval;
        END LOOP;
        WHILE FLOOR((extract(day from next_date+'1 month'::interval-next_date)-extract(day from next_date))/7) < FLOOR((extract(day from original_date+'1 month'::interval-original_date)-extract(day from original_date))/7) LOOP
          next_date := next_date - '7 days'::interval;
        END LOOP;
      END IF;
    END LOOP;
  ELSE
    next_date := original_date + duration * CEIL(intervals_between(original_date, range_start, duration));
    WHILE next_date <= range_end LOOP
      RETURN NEXT next_date;
      next_date := next_date + duration;
    END LOOP;
  END IF;
END;
$BODY$;
