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
  next_date := original_date + duration * (CEIL(intervals_between(original_date, range_start, duration))-1);
  IF pattern_type = 'positive_week_dow' OR pattern_type = 'negative_week_dow' THEN
    LOOP
      -- increase by 2 durations if 1 will put us in the same month
      IF extract(year from next_date + duration) = extract(year from next_date) AND extract(month from next_date + duration) = extract(month from duration) THEN
        next_date := next_date + duration;
      END IF;
      next_date := next_date + duration;

      -- Yearly events could be put in the wrong month since 364 days is less than a year.
      -- This has to be a while loop since 28 days is sometimes less than a month,
      -- so next_date might not be pushed all the way into the right month.
      WHILE duration = '364 days'::interval AND extract(month from next_date) != extract(month from original_date) LOOP
        IF extract(month from next_date) > extract(month from original_date) THEN
          next_date := next_date + (12 - (extract(month from next_date) - extract(month from original_date))) * '28 days'::interval;
        ELSE
          next_date := next_date + (extract(month from original_date) - extract(month from next_date)) * '28 days'::interval;
        END IF;
      END LOOP;

      IF pattern_type = 'positive_week_dow' THEN
        next_date := next_date
          + (CEIL(extract(day from original_date) / 7)
            - CEIL(extract(day from next_date) / 7))
          * '7 days'::interval;
      ELSE
        next_date := next_date
          + (FLOOR((extract(day from original_date + '1 month'::interval - original_date) - extract(day from original_date)) / 7)
            - FLOOR((extract(day from next_date + '1 month'::interval - next_date) - extract(day from next_date)) / 7))
          * '7 days'::interval;
      END IF;
      EXIT WHEN next_date > range_end;
      RETURN NEXT next_date;
    END LOOP;
  ELSE
    LOOP
      next_date := next_date + duration;
      EXIT WHEN next_date > range_end;
      RETURN NEXT next_date;
    END LOOP;
  END IF;
END;
$BODY$;
