DROP TABLE IF EXISTS event_cancellations CASCADE;
DROP TABLE IF EXISTS event_recurrences CASCADE;
DROP TABLE IF EXISTS events CASCADE;

CREATE TABLE events (
  id serial PRIMARY KEY,
  date date,
  starts_at timestamp without time zone,
  ends_at timestamp without time zone,
  frequency character varying(255),
  count integer,
  "until" date
);

CREATE TABLE event_recurrences (
  id serial PRIMARY KEY,
  event_id integer,
  "month" integer,
  "day" integer,
  week integer
);
ALTER TABLE event_recurrences ADD CONSTRAINT event FOREIGN KEY (event_id) REFERENCES events (id);

CREATE TABLE event_cancellations (
  id serial PRIMARY KEY,
  event_id integer,
  date date
);
ALTER TABLE event_cancellations ADD CONSTRAINT event FOREIGN KEY (event_id) REFERENCES events (id);
