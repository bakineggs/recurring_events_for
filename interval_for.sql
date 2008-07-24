CREATE OR REPLACE FUNCTION  interval_for(
  recurs frequency
)
  RETURNS INTERVAL
  LANGUAGE plpgsql IMMUTABLE
  AS $BODY$
BEGIN
  IF recurs = 'daily' THEN
    RETURN '1 day'::interval;
  ELSIF recurs = 'weekly' THEN
    RETURN '7 days'::interval;
  ELSIF recurs = 'monthly' THEN
    RETURN '1 month'::interval;
  ELSIF recurs = 'yearly' THEN
    RETURN '1 year'::interval;
  ELSE
    RAISE EXCEPTION 'Recurrence % not supported by generate_recurrences()', recurs;
  END IF;
END;
$BODY$;
