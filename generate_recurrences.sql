CREATE OR REPLACE FUNCTION  generate_recurrences(
  duration INTERVAL,
  range_start DATE,
  range_end DATE,
  repeat_month INT,
  repeat_week INT,
  repeat_day INT
)
  RETURNS setof DATE
  LANGUAGE plpgsql IMMUTABLE
  AS $BODY$
DECLARE
  next_date DATE := range_start;
  current_month INT;
  current_week INT;
BEGIN
  IF repeat_month IS NOT NULL THEN
    next_date := next_date + (((12 + repeat_month - cast(extract(month from next_date) as int)) % 12) || ' months')::interval;
  END IF;
  IF repeat_week IS NULL AND repeat_day IS NOT NULL THEN
    IF duration = '7 days'::interval THEN
      next_date := next_date + (((7 + repeat_day - cast(extract(dow from next_date) as int)) % 7) || ' days')::interval;
    ELSE
      next_date := next_date + (repeat_day - extract(day from next_date) || ' days')::interval;
    END IF;
  END IF;
  LOOP
    IF repeat_week IS NOT NULL AND repeat_day IS NOT NULL THEN
      current_month := extract(month from next_date);
      next_date := next_date + (((7 + repeat_day - cast(extract(dow from next_date) as int)) % 7) || ' days')::interval;
      IF extract(month from next_date) != current_month THEN
        next_date := next_date - '7 days'::interval;
      END IF;
      IF repeat_week > 0 THEN
        current_week := CEIL(extract(day from next_date) / 7);
      ELSE
        current_week := -CEIL((1 + days_in_month(next_date) - extract(day from next_date)) / 7);
      END IF;
      next_date := next_date + (repeat_week - current_week) * '7 days'::interval;
    END IF;
    EXIT WHEN next_date > range_end;
    IF next_date >= range_start THEN
      RETURN NEXT next_date;
    END IF;
    next_date := next_date + duration;
  END LOOP;
END;
$BODY$;
