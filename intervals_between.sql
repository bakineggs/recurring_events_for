CREATE OR REPLACE FUNCTION  intervals_between(
  start_date DATE,
  end_date DATE,
  duration INTERVAL
)
  RETURNS FLOAT
  LANGUAGE plpgsql IMMUTABLE
  AS $BODY$
DECLARE
  count FLOAT := 0;
BEGIN
  IF start_date > end_date THEN
    RETURN 0;
  END IF;
  WHILE start_date + count * duration < end_date LOOP
    count := count + 1;
  END LOOP;
  count := count + (extract(epoch from end_date) - extract(epoch from (start_date + count * duration))) / (extract(epoch from end_date + duration) - extract(epoch from end_date))::int;
  RETURN count;
END
$BODY$;
