CREATE OR REPLACE FUNCTION  days_in_month(
  check_date DATE
)
  RETURNS INT
  LANGUAGE plpgsql IMMUTABLE
  AS $BODY$
DECLARE
  first_of_month DATE := check_date - ((extract(day from check_date) - 1)||' days')::interval;
BEGIN
  RETURN extract(day from first_of_month + '1 month'::interval - first_of_month);
END;
$BODY$;
