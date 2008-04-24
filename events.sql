CREATE DOMAIN recurrence AS TEXT
CHECK ( VALUE IN ( 'none', 'daily', 'weekly', 'monthly' ) );

CREATE TABLE events (
  id         SERIAL     PRIMARY KEY,
  user_id    INTEGER    NOT NULL,
  starts_at  TIMESTAMP  NOT NULL,
  start_tz   TEXT       NOT NULL,
  ends_at    TIMESTAMP,
  end_tz     TEXT       NOT NULL,
  recurrence RECURRENCE NOT NULL DEFAULT 'none'
);
