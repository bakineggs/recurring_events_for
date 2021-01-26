DROP TABLE IF EXISTS event_cancellations CASCADE;
DROP TABLE IF EXISTS event_recurrences CASCADE;
DROP TABLE IF EXISTS events CASCADE;

DROP DOMAIN IF EXISTS frequency CASCADE;
CREATE DOMAIN frequency AS CHARACTER VARYING CHECK ( VALUE IN ( 'once', 'daily', 'weekly', 'monthly', 'yearly' ) );

CREATE TABLE events (
  id serial PRIMARY KEY,
  starts_at timestamp without time zone not null,
  ends_at timestamp without time zone,
  frequency frequency,
  separation integer not null default 1 constraint positive_separation check (separation > 0),
  count integer,
  "until" date,
  timezone_name text not null default 'Etc/UTC',
  is_full_day bool not null default false,
  CHECK (
    is_full_day = FALSE AND ends_at IS NOT NULL OR
    is_full_day = TRUE)
);

CREATE TABLE event_recurrences (
  id serial PRIMARY KEY,
  event_id integer,
  "month" integer,
  "day" integer,
  week integer
);
ALTER TABLE event_recurrences ADD CONSTRAINT event FOREIGN KEY (event_id) REFERENCES events (id);

CREATE INDEX IDX_EVENT_RECURRENCE_EVENT_ID ON event_recurrences(event_id);

CREATE TABLE event_cancellations (
  id serial PRIMARY KEY,
  event_id integer,
  date date
);
ALTER TABLE event_cancellations ADD CONSTRAINT event FOREIGN KEY (event_id) REFERENCES events (id);

CREATE INDEX IDX_EVENT_CANCELLATIONS_EVENT_ID ON event_cancellations(event_id);