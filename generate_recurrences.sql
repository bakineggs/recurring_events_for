CREATE OR REPLACE FUNCTION  generate_recurrences(
  recurs RECURRENCE, 
  start_date DATE,
  end_date DATE
)
  RETURNS setof DATE
  LANGUAGE plpgsql IMMUTABLE
  AS $BODY$
DECLARE
  next_date DATE := start_date;
  duration  INTERVAL;
  day       INTERVAL;
  check     TEXT;
BEGIN
  IF recurs = 'none' THEN
    -- Only one date ever.
    RETURN next next_date;
  ELSIF recurs = 'weekly' THEN
    duration := '7 days'::interval;
    WHILE next_date <= end_date LOOP
      RETURN NEXT next_date;
      next_date := next_date + duration;
    END LOOP;
  ELSIF recurs = 'daily' THEN
    duration := '1 day'::interval;
    WHILE next_date <= end_date LOOP
      RETURN NEXT next_date;
      next_date := next_date + duration;
    END LOOP;
  ELSIF recurs = 'monthly' THEN
    duration := '27 days'::interval;
    day      := '1 day'::interval;
    check    := to_char(start_date, 'DD');
    WHILE next_date <= end_date LOOP
      RETURN NEXT next_date;
      next_date := next_date + duration;
      WHILE to_char(next_date, 'DD') <> check LOOP
        next_date := next_date + day;
      END LOOP;
    END LOOP;
  ELSE
    -- Someone needs to update this function, methinks.
    RAISE EXCEPTION 'Recurrence % not supported by generate_recurrences()', recurs;
  END IF;
END;
$BODY$;
