CREATE OR REPLACE FUNCTION  generate_recurrences(
  recurs TEXT,
  start_date DATE,
  end_date DATE
)
  RETURNS setof DATE
  LANGUAGE plpgsql IMMUTABLE
  AS $BODY$
DECLARE
  next_date DATE := start_date;
  duration INTERVAL;
BEGIN
  IF recurs = 'daily' THEN
    duration := '1 day'::interval;
  ELSIF recurs = 'weekly' THEN
    duration := '7 days'::interval;
  ELSIF recurs = 'monthly' THEN
    duration := '1 month'::interval;
  ELSIF recurs = 'yearly' THEN
    duration := '1 year'::interval;
  ELSIF recurs = 'monthly_positive_week_dow' OR recurs = 'monthly_negative_week_dow' THEN
    duration := '28 days'::interval;
  ELSIF recurs = 'yearly_positive_week_dow' OR recurs = 'yearly_negative_week_dow' THEN
    duration := '364 days'::interval;
  ELSE
    RAISE EXCEPTION 'Recurrence % not supported by generate_recurrences()', recurs;
  END IF;
  IF recurs = 'once' THEN
    RETURN NEXT next_date;
  ELSIF recurs = 'monthly_positive_week_dow' OR recurs = 'yearly_positive_week_dow' THEN
    WHILE next_date <= end_date LOOP
      RETURN NEXT next_date;
      next_date := next_date + duration;
      IF recurs = 'yearly_positive_week_dow' AND extract(month from next_date) != extract(month from start_date) THEN
        next_date := next_date + '7 days'::interval;
      END IF;
      WHILE CEIL(extract(day from next_date)/7) > CEIL(extract(day from start_date)/7) LOOP
        next_date := next_date - '7 days'::interval;
      END LOOP;
      WHILE CEIL(extract(day from next_date)/7) < CEIL(extract(day from start_date)/7) LOOP
        next_date := next_date + '7 days'::interval;
      END LOOP;
    END LOOP;
  ELSIF recurs = 'monthly_negative_week_dow' OR recurs = 'yearly_negative_week_dow' THEN
    WHILE next_date <= end_date LOOP
      RETURN NEXT next_date;
      next_date := next_date + duration;
      IF recurs = 'yearly_negative_week_dow' AND extract(month from next_date) != extract(month from start_date) THEN
        next_date := next_date + '7 days'::interval;
      END IF;
      WHILE FLOOR((extract(day from next_date+'1 month'::interval-next_date)-extract(day from next_date))/7) > FLOOR((extract(day from start_date+'1 month'::interval-start_date)-extract(day from start_date))/7) LOOP
        next_date := next_date + '7 days'::interval;
      END LOOP;
      WHILE FLOOR((extract(day from next_date+'1 month'::interval-next_date)-extract(day from next_date))/7) < FLOOR((extract(day from start_date+'1 month'::interval-start_date)-extract(day from start_date))/7) LOOP
        next_date := next_date - '7 days'::interval;
      END LOOP;
    END LOOP;
  ELSE
    WHILE next_date <= end_date LOOP
      RETURN NEXT next_date;
      next_date := next_date + duration;
    END LOOP;
  END IF;
END;
$BODY$;
