require File.dirname(__FILE__) + '/helper'

describe 'recurring_events_for' do
  describe 'on single day events:' do
    it "should include events on a date inside of the range" do
      executing([
        "insert into events (starts_on, frequency) values ('2008-04-25', 'once');",
        "select starts_on from recurring_events_for('2008-04-24 12:00pm', '2008-04-26 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-25']
      ]
    end

    it "should include events on the date of the start of the range" do
      executing([
        "insert into events (starts_on, frequency) values ('2008-04-25', 'once');",
        "select starts_on from recurring_events_for('2008-04-25 12:00pm', '2008-04-26 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-25']
      ]
    end

    it "should include events on the date of the end of the range" do
      executing([
        "insert into events (starts_on, frequency) values ('2008-04-25', 'once');",
        "select starts_on from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-25']
      ]
    end

    it "should include events on the date of the end of the range when the range ends at midnight" do
      executing([
        "insert into events (starts_on, frequency) values ('2008-04-25', 'once');",
        "select starts_on from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 12:00am', 'UTC', NULL);"
      ]).should == [
        ['2008-04-25']
      ]
    end

    it "should not include events on a date outside of the range" do
      executing([
        "insert into events (starts_on, frequency) values ('2008-04-23', 'once');",
        "select starts_on from recurring_events_for('2008-04-24 12:00pm', '2008-04-26 12:00pm', 'UTC', NULL);"
      ]).should == []
    end
  end

  describe 'on multi-day events:' do
    it "should include events starting and ending on the endpoints of the range" do
      executing([
        "insert into events (starts_on, ends_on, frequency) values ('2008-04-24', '2008-04-25', 'once');",
        "select starts_on, ends_on from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-24', '2008-04-25']
      ]
    end

    it "should include events ending on the day the range begins" do
      executing([
        "insert into events (starts_on, ends_on, frequency) values ('2008-04-20', '2008-04-24', 'once');",
        "select starts_on, ends_on from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-20', '2008-04-24']
      ]
    end

    it "should include events starting on the day the range ends" do
      executing([
        "insert into events (starts_on, ends_on, frequency) values ('2008-04-25', '2008-04-26', 'once');",
        "select starts_on, ends_on from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-25', '2008-04-26']
      ]
    end

    it "should not include events starting after the range ends" do
      executing([
        "insert into events (starts_on, ends_on, frequency) values ('2008-04-26', '2008-04-28', 'once');",
        "select starts_on, ends_on from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 12:00pm', 'UTC', NULL);"
      ]).should == []
    end

    it "should not include events ending before the range begins" do
      executing([
        "insert into events (starts_on, ends_on, frequency) values ('2008-04-20', '2008-04-23', 'once');",
        "select starts_on, ends_on from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 12:00pm', 'UTC', NULL);"
      ]).should == []
    end
  end

  describe 'on timespan events:' do
    it "should include events starting and ending inside the range" do
      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-04-25 12:00pm', '2008-04-26 12:00pm', 'once');",
        "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-27 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-25 12:00:00', '2008-04-26 12:00:00']
      ]
    end

    it "should include events starting inside the range" do
      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-04-25 12:00pm', '2008-04-27 12:00pm', 'once');",
        "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-26 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-25 12:00:00', '2008-04-27 12:00:00']
      ]
    end

    it "should include events ending inside the range" do
      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-04-24 12:00pm', '2008-04-26 12:00pm', 'once');",
        "select starts_at, ends_at from recurring_events_for('2008-04-25 12:00pm', '2008-04-27 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-24 12:00:00', '2008-04-26 12:00:00']
      ]
    end

    it "should include events starting at the end of the range" do
      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-04-25 12:00pm', '2008-04-26 12:00pm', 'once');",
        "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-25 12:00:00', '2008-04-26 12:00:00']
      ]
    end

    it "should include events ending at the start of the range" do
      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-04-25 12:00pm', '2008-04-26 12:00pm', 'once');",
        "select starts_at, ends_at from recurring_events_for('2008-04-26 12:00pm', '2008-04-27 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-25 12:00:00', '2008-04-26 12:00:00']
      ]
    end

    it "should include events encapsulating the range" do
      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-04-24 12:00pm', '2008-04-27 12:00pm', 'once');",
        "select starts_at, ends_at from recurring_events_for('2008-04-25 12:00pm', '2008-04-26 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-24 12:00:00', '2008-04-27 12:00:00']
      ]
    end

    it "should not include events ending before the range start" do
      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-04-24 12:00pm', '2008-04-25 12:00pm', 'once');",
        "select starts_at, ends_at from recurring_events_for('2008-04-26 12:00pm', '2008-04-27 12:00pm', 'UTC', NULL);"
      ]).should == []
    end

    it "should not include events starting after the range end" do
      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-04-26 12:00pm', '2008-04-27 12:00pm', 'once');",
        "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 12:00pm', 'UTC', NULL);"
      ]).should == []
    end
  end

  it "should not include the same date twice" do
    executing([
      "insert into events (id, starts_on, frequency) values (1, '2008-05-30', 'monthly');",
      "insert into event_recurrences (event_id, day) values (1, 30)",
      "insert into event_recurrences (event_id, week, day) values (1, 5, 5)",
      "select starts_on from recurring_events_for('2008-05-29 12:00pm', '2008-05-31 12:00pm', 'UTC', NULL)"
    ]).should == [
      ['2008-05-30']
    ]
  end

  describe 'time zone' do
    it "should return starts_at and ends_at in UTC" do
      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-04-25 12:00pm', '2008-04-26 12:00pm', 'once');",
        "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-27 12:00pm', 'America/Chicago', NULL);"
      ]).should == [
        ['2008-04-25 12:00:00', '2008-04-26 12:00:00']
      ]
    end

    it "should take time zone into account when deciding whether or not a date is in the range" do
      executing([
        "insert into events (starts_on, frequency) values ('2008-05-12', 'once');",
        "select starts_on from recurring_events_for('2008-05-13 4:59am', '2008-05-13 12:00pm', 'America/Chicago', NULL);"
      ]).should == [
        ['2008-05-12']
      ]

      executing([
        "insert into events (starts_on, frequency) values ('2008-05-12', 'once');",
        "select starts_on from recurring_events_for('2008-05-11 12:00pm', '2008-05-11 7:00pm', 'Indian/Maldives', NULL);"
      ]).should == [
        ['2008-05-12']
      ]

      executing([
        "insert into events (starts_on, frequency) values ('2008-05-12', 'once');",
        "select starts_on from recurring_events_for('2008-05-13 5:00am', '2008-05-13 12:00pm', 'America/Chicago', NULL);"
      ]).should == []

      executing([
        "insert into events (starts_on, frequency) values ('2008-05-12', 'once');",
        "select starts_on from recurring_events_for('2008-05-11 12:00pm', '2008-05-11 6:59pm', 'Indian/Maldives', NULL);"
      ]).should == []
    end

    it "should take time zone into account when deciding whether or not a day of a time span event is in the range" do
      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-05-12 2:00am', '2008-05-12 3:00am', 'once');",
        "select starts_at from recurring_events_for('2008-05-12 1:00am', '2008-05-12 2:00am', 'America/Chicago', NULL);"
      ]).should == [
        ['2008-05-12 02:00:00']
      ]

      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-05-12 9:00pm', '2008-05-12 10:00pm', 'once');",
        "select starts_at from recurring_events_for('2008-05-12 10:00pm', '2008-05-12 11:00pm', 'Indian/Maldives', NULL);"
      ]).should == [
        ['2008-05-12 21:00:00']
      ]
    end
  end

  describe 'recurring' do
    describe 'time zone' do
      it "should return starts_at and ends_at in UTC" do
        executing([
          "insert into events (starts_at, ends_at, frequency) values ('2008-04-18 12:00pm', '2008-04-19 12:00pm', 'weekly');",
          "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-27 12:00pm', 'America/Chicago', NULL);"
        ]).should == [
          ['2008-04-25 12:00:00', '2008-04-26 12:00:00']
        ]
      end

      it "should take time zone into account when deciding whether or not a date is in the range" do
        executing([
          "insert into events (starts_on, frequency) values ('2008-05-12', 'weekly');",
          "select starts_on from recurring_events_for('2008-05-20 4:59am', '2008-05-20 12:00pm', 'America/Chicago', NULL);"
        ]).should == [
          ['2008-05-19']
        ]

        executing([
          "insert into events (starts_on, frequency) values ('2008-05-12', 'weekly');",
          "select starts_on from recurring_events_for('2008-05-18 12:00pm', '2008-05-18 7:00pm', 'Indian/Maldives', NULL);"
        ]).should == [
          ['2008-05-19']
        ]

        executing([
          "insert into events (starts_on, frequency) values ('2008-05-12', 'weekly');",
          "select starts_on from recurring_events_for('2008-05-20 5:00am', '2008-05-20 12:00pm', 'America/Chicago', NULL);"
        ]).should == []

        executing([
          "insert into events (starts_on, frequency) values ('2008-05-12', 'weekly');",
          "select starts_on from recurring_events_for('2008-05-18 12:00pm', '2008-05-18 6:59pm', 'Indian/Maldives', NULL);"
        ]).should == []
      end

      it "should take time zone into account when deciding whether a day of a multi-day event is in the range" do
        executing([
          "insert into events (starts_on, ends_on, frequency) values ('2008-05-12', '2008-05-13', 'weekly');",
          "select starts_on, ends_on from recurring_events_for('2008-05-18 7:00pm', '2008-05-19 12:00pm', 'America/Chicago', NULL);"
        ]).should == [
          ['2008-05-19', '2008-05-20']
        ]

        executing([
          "insert into events (starts_on, ends_on, frequency) values ('2008-05-12', '2008-05-13', 'weekly');",
          "select starts_on, ends_on from recurring_events_for('2008-05-18 12:00pm', '2008-05-18 6:59pm', 'America/Chicago', NULL);"
        ]).should == []
      end

      it "should take daylight savings time into account when deciding whether a day of a multi-day event is in the range" do
        executing([
          "SET TIMEZONE TO 'America/Chicago';",
          "insert into events (starts_on, ends_on, frequency) values ('2009-02-24', '2009-03-09', 'yearly');",
          "select starts_on, ends_on from recurring_events_for('2009-02-24 06:00:00.000000', '2009-02-25 05:59:59.000000', E'America/Chicago', NULL);"
        ]).should == [
          ['2009-02-24', '2009-03-09']
        ]
      end

      it "should take time zone into account when deciding whether or not a day of a time span event is in the range" do
        executing([
          "insert into events (starts_at, ends_at, frequency) values ('2008-05-12 2:00am', '2008-05-12 3:00am', 'weekly');",
          "select starts_at from recurring_events_for('2008-05-19 1:00am', '2008-05-19 2:00am', 'America/Chicago', NULL);"
        ]).should == [
          ['2008-05-19 02:00:00']
        ]

        executing([
          "insert into events (starts_at, ends_at, frequency) values ('2008-05-12 9:00pm', '2008-05-12 10:00pm', 'weekly');",
          "select starts_at from recurring_events_for('2008-05-19 10:00pm', '2008-05-19 11:00pm', 'Indian/Maldives', NULL);"
        ]).should == [
          ['2008-05-19 21:00:00']
        ]
      end

      describe 'that observe dst' do
        it "should adjust the start time and end time of the event to be earlier when DST starts" do
          executing([
            "insert into events (starts_at, ends_at, frequency, timezone_name) values ('2009-03-07 9:00pm', '2009-03-07 10:00pm', 'daily', 'America/Chicago');",
            "select starts_at, ends_at from recurring_events_for('2009-03-07 7:00pm', '2009-03-08 11:59pm', 'America/Chicago', NULL);"
          ]).should == [
            ['2009-03-07 21:00:00', '2009-03-07 22:00:00'],
            ['2009-03-08 20:00:00', '2009-03-08 21:00:00']
          ]
        end

        it "should report the original start time when DST ends" do
          executing([
            "insert into events (starts_at, ends_at, frequency, timezone_name) values ('2009-03-07 9:00pm', '2009-03-07 10:00pm', 'daily', 'America/Chicago');",
            "select starts_at, ends_at from recurring_events_for('2009-10-31 7:00pm', '2009-11-01 11:59pm', 'America/Chicago', NULL);"
          ]).should == [
            ['2009-10-31 20:00:00', '2009-10-31 21:00:00'],
            ['2009-11-01 21:00:00', '2009-11-01 22:00:00']
          ]
        end

        it "should adjust the start time and end time of the event to be later when DST ends" do
          executing([
            "insert into events (starts_at, ends_at, frequency, timezone_name) values ('2009-10-31 9:00pm', '2009-10-31 10:00pm', 'daily', 'America/Chicago');",
            "select starts_at, ends_at from recurring_events_for('2009-10-31 7:00pm', '2009-11-1 11:59pm', 'America/Chicago', NULL);"
          ]).should == [
            ['2009-10-31 21:00:00', '2009-10-31 22:00:00'],
            ['2009-11-01 22:00:00', '2009-11-01 23:00:00']
          ]
        end

        it "should report the original start time when DST begins again" do
          executing([
            "insert into events (starts_at, ends_at, frequency, timezone_name) values ('2009-10-31 9:00pm', '2009-10-31 10:00pm', 'daily', 'America/Chicago');",
            "select starts_at, ends_at from recurring_events_for('2010-03-13 7:00pm', '2010-03-14 11:59pm', 'America/Chicago', NULL);"
          ]).should == [
            ['2010-03-13 22:00:00', '2010-03-13 23:00:00'],
            ['2010-03-14 21:00:00', '2010-03-14 22:00:00']
          ]
        end

        it "should work even if the DB's timezone isn't in UTC" do
          executing([
            "SET TIMEZONE TO 'America/Chicago';",
            "insert into events (starts_at, ends_at, frequency, timezone_name) values ('2009-03-07 9:00pm', '2009-03-07 10:00pm', 'daily', 'America/Chicago');",
            "select starts_at, ends_at from recurring_events_for('2009-03-07 7:00pm', '2009-03-08 11:59pm', 'America/Chicago', NULL);"
          ]).should == [
            ['2009-03-07 21:00:00', '2009-03-07 22:00:00'],
            ['2009-03-08 20:00:00', '2009-03-08 21:00:00']
          ]
        end
      end

      describe 'that do not observe dst' do
        it "should adjust the start time and end time of the event to be later when DST starts" do
          executing([
            "insert into events (starts_at, ends_at, frequency, timezone_name) values ('2009-03-07 9:00pm', '2009-03-07 10:00pm', 'daily', 'America/Phoenix');",
            "select starts_at, ends_at from recurring_events_for('2009-03-07 7:00pm', '2009-03-08 11:59pm', 'America/Phoenix', NULL);"
          ]).should == [
            ['2009-03-07 21:00:00', '2009-03-07 22:00:00'],
            ['2009-03-08 21:00:00', '2009-03-08 22:00:00']
          ]
        end

        it "should report the original start time when DST ends" do
          executing([
            "insert into events (starts_at, ends_at, frequency, timezone_name) values ('2009-03-07 9:00pm', '2009-03-07 10:00pm', 'daily', 'America/Phoenix');",
            "select starts_at, ends_at from recurring_events_for('2009-10-31 7:00pm', '2009-11-01 11:59pm', 'America/Phoenix', NULL);"
          ]).should == [
            ['2009-10-31 21:00:00', '2009-10-31 22:00:00'],
            ['2009-11-01 21:00:00', '2009-11-01 22:00:00']
          ]
        end

        it "should adjust the start time and end time of the event to be earlier when DST ends" do
          executing([
            "insert into events (starts_at, ends_at, frequency, timezone_name) values ('2009-10-31 9:00pm', '2009-10-31 10:00pm', 'daily', 'America/Phoenix');",
            "select starts_at, ends_at from recurring_events_for('2009-10-31 7:00pm', '2009-11-1 11:59pm', 'America/Phoenix', NULL);"
          ]).should == [
            ['2009-10-31 21:00:00', '2009-10-31 22:00:00'],
            ['2009-11-01 21:00:00', '2009-11-01 22:00:00']
          ]
        end

        it "should report the original start time when DST begins again" do
          executing([
            "insert into events (starts_at, ends_at, frequency, timezone_name) values ('2009-10-31 9:00pm', '2009-10-31 10:00pm', 'daily', 'America/Phoenix');",
            "select starts_at, ends_at from recurring_events_for('2010-03-13 7:00pm', '2010-03-14 11:59pm', 'America/Phoenix', NULL);"
          ]).should == [
            ['2010-03-13 21:00:00', '2010-03-13 22:00:00'],
            ['2010-03-14 21:00:00', '2010-03-14 22:00:00']
          ]
        end
      end

    end

    it "should only include events before or on the until date" do
      executing([
        "insert into events (starts_on, frequency, until) values ('2008-04-25', 'daily', '2008-04-27');",
        "select starts_on from recurring_events_for('2008-04-24 12:00pm', '2008-04-29 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-25'],
        ['2008-04-26'],
        ['2008-04-27']
      ]
    end

    it "should only include events for count recurrences" do
      executing([
        "insert into events (starts_on, frequency, count) values ('2008-04-25', 'daily', 3);",
        "select starts_on from recurring_events_for('2008-04-24 12:00pm', '2008-04-29 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-25'],
        ['2008-04-26'],
        ['2008-04-27']
      ]
    end

    it "should not include additional recurrences when the range starts after the event" do
      executing([
        "insert into events (starts_on, frequency, count) values ('2008-04-25', 'daily', 3);",
        "select starts_on from recurring_events_for('2008-04-27 12:00pm', '2008-04-29 12:00pm', 'UTC', NULL);"
      ]).should == [
        ['2008-04-27']
      ]
    end

    it "should only include limit recurrences of each event" do
      executing([
        "insert into events (starts_on, frequency) values ('2008-04-20', 'daily');",
        "insert into events (starts_on, frequency) values ('2008-04-25', 'daily');",
        "select starts_on from recurring_events_for('2008-04-19 12:00pm', '2008-04-29 12:00pm', 'UTC', 3)"
      ]).should == [
        ['2008-04-20'],
        ['2008-04-21'],
        ['2008-04-22'],
        ['2008-04-25'],
        ['2008-04-26'],
        ['2008-04-27']
      ]
    end

    describe 'mutliple recurrence rules' do
      it "should only include events for count recurrences" do
        executing([
          "insert into events (id, starts_on, frequency, count) values (1, '2008-04-25', 'monthly', 3);",
          "insert into event_recurrences (event_id, day) values (1, 28);",
          "insert into event_recurrences (event_id, day) values (1, 4);",
          "select starts_on from recurring_events_for('2008-04-01 12:00pm', '2008-06-25 12:00pm', 'UTC', NULL);"
        ]).should == [
          ['2008-04-25'],
          ['2008-04-28'],
          ['2008-05-04']
        ]
      end

      it "should only include limit recurrences of each event" do
        executing([
          "insert into events (id, starts_on, frequency) values (1, '2008-04-20', 'monthly');",
          "insert into event_recurrences (event_id, day) values (1, 28);",
          "insert into event_recurrences (event_id, day) values (1, 4);",
          "insert into events (id, starts_on, frequency) values (2, '2008-04-25', 'monthly');",
          "insert into event_recurrences (event_id, day) values (2, 14);",
          "insert into event_recurrences (event_id, day) values (2, 7);",
          "select starts_on from recurring_events_for('2008-04-19 12:00pm', '2009-04-29 12:00pm', 'UTC', 3)"
        ]).should == [
          ['2008-04-20'],
          ['2008-04-28'],
          ['2008-05-04'],
          ['2008-04-25'],
          ['2008-05-07'],
          ['2008-05-14']
        ]
      end

      it "should put separation in between each recurrence" do
        executing([
          "insert into events (id, starts_on, frequency, separation) values (1, '2008-04-25', 'monthly', 2);",
          "insert into event_recurrences (event_id, day) values (1, 28);",
          "insert into event_recurrences (event_id, day) values (1, 4);",
          "select starts_on from recurring_events_for('2008-04-01 12:00pm', '2008-08-25 12:00pm', 'UTC', NULL);"
        ]).should == [
          ['2008-04-25'],
          ['2008-04-28'],
          ['2008-06-04'],
          ['2008-06-28'],
          ['2008-08-04']
        ]
      end
    end

    describe 'cancellations' do
      it "should not include cancelled recurrences" do
        executing([
          "insert into events (id, starts_on, frequency) values (1, '2008-04-25', 'daily');",
          "insert into event_cancellations (event_id, date) values (1, '2008-04-26')",
          "select starts_on from recurring_events_for('2008-04-26 12:00pm', '2008-04-26 1:00pm', 'UTC', NULL);"
        ]).should == []
      end

      it "should still include uncancelled recurrences" do
        executing([
          "insert into events (id, starts_on, frequency) values (1, '2008-04-25', 'daily');",
          "insert into event_cancellations (event_id, date) values (1, '2008-04-26')",
          "select starts_on from recurring_events_for('2008-04-25 12:00pm', '2008-04-27 12:00pm', 'UTC', NULL);"
        ]).should == [
          ['2008-04-25'],
          ['2008-04-27']
        ]
      end

      it "should still have recurrences if the first was cancelled" do
        executing([
          "insert into events (id, starts_on, frequency) values (1, '2008-04-25', 'daily');",
          "insert into event_cancellations (event_id, date) values (1, '2008-04-25')",
          "select starts_on from recurring_events_for('2008-04-26 12:00pm', '2008-04-26 1:00pm', 'UTC', NULL);"
        ]).should == [
          ['2008-04-26']
        ]
      end

      it "should not include additional recurrences for events restricted by count" do
        executing([
          "insert into events (id, starts_on, frequency, count) values (1, '2008-04-25', 'daily', 3);",
          "insert into event_cancellations (event_id, date) values (1, '2008-04-26')",
          "select starts_on from recurring_events_for('2008-04-25 12:00pm', '2008-04-28 12:00pm', 'UTC', NULL);"
        ]).should == [
          ['2008-04-25'],
          ['2008-04-27']
        ]
      end

      it "should include additional recurrences when specifying a limit" do
        executing([
          "insert into events (id, starts_on, frequency) values (1, '2008-04-25', 'daily');",
          "insert into event_cancellations (event_id, date) values (1, '2008-04-26')",
          "select starts_on from recurring_events_for('2008-04-25 12:00pm', '2008-04-29 12:00pm', 'UTC', 3);"
        ]).should == [
          ['2008-04-25'],
          ['2008-04-27'],
          ['2008-04-28']
        ]
      end
    end

    describe 'daily' do
      it "should include the event once for each day" do
        executing([
          "insert into events (starts_on, frequency) values ('2008-04-25', 'daily');",
          "select starts_on from recurring_events_for('2008-04-01 12:00pm', '2008-04-26 1:00pm', 'UTC', NULL);"
        ]).should == [
          ['2008-04-25'],
          ['2008-04-26']
        ]
      end

      it "should put separation in between each recurrence" do
        executing([
          "insert into events (starts_on, frequency, separation) values ('2008-04-25', 'daily', 2);",
          "select starts_on from recurring_events_for('2008-04-24 12:00pm', '2008-04-30 12:00pm', 'UTC', NULL);"
        ]).should == [
          ['2008-04-25'],
          ['2008-04-27'],
          ['2008-04-29']
        ]
      end
    end

    describe 'weekly' do
      it "should include the event once for each week" do
        executing([
          "insert into events (starts_on, frequency) values ('2008-04-25', 'weekly');",
          "select starts_on from recurring_events_for('2008-04-01 12:00pm', '2008-05-08 12:00pm', 'UTC', NULL);"
        ]).should == [
          ['2008-04-25'],
          ['2008-05-02']
        ]
      end

      it "should put separation in between each recurrence" do
        executing([
          "insert into events (starts_on, frequency, separation) values ('2008-04-25', 'weekly', 2);",
          "select starts_on from recurring_events_for('2008-04-01 12:00pm', '2008-05-10 12:00pm', 'UTC', NULL);"
        ]).should == [
          ['2008-04-25'],
          ['2008-05-09']
        ]
      end

      describe 'using a custom day of week' do
        it "should include the event once for each occurrence" do
          executing([
            "insert into events (id, starts_on, frequency) values (1, '2008-04-25', 'weekly');",
            "insert into event_recurrences (event_id, day) values (1, 2);",
            "insert into event_recurrences (event_id, day) values (1, 4);",
            "select starts_on from recurring_events_for('2008-04-01 12:00pm', '2008-05-02 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2008-04-29'],
            ['2008-05-01']
          ]
        end

        it "should put separation in between each recurrence" do
          executing([
            "insert into events (id, starts_on, frequency, separation) values (1, '2008-04-25', 'weekly', 2);",
            "insert into event_recurrences (event_id, day) values (1, 2);",
            "insert into event_recurrences (event_id, day) values (1, 4);",
            "select starts_on from recurring_events_for('2008-04-01 12:00pm', '2008-05-16 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2008-04-29'],
            ['2008-05-01'],
            ['2008-05-13'],
            ['2008-05-15']
          ]
        end
      end
    end

    describe 'monthly' do
      it "should include the event once for each month" do
        executing([
          "insert into events (starts_on, frequency) values ('2008-04-25', 'monthly');",
          "select starts_on from recurring_events_for('2008-03-01 12:00pm', '2008-06-24 12:00pm', 'UTC', NULL);"
        ]).should == [
          ['2008-04-25'],
          ['2008-05-25']
        ]
      end

      it "should maintain the day of month for events at the end of the month" do
        executing([
          "insert into events (starts_on, frequency) values ('2008-05-31', 'monthly');",
          "select starts_on from recurring_events_for('2008-06-30 12:00pm', '2008-08-01 12:00pm', 'UTC', NULL);"
        ]).should == [
          ['2008-06-30'],
          ['2008-07-31']
        ]
      end

      it "should put separation in between each recurrence" do
        executing([
          "insert into events (starts_on, frequency, separation) values ('2008-04-25', 'monthly', 2);",
          "select starts_on from recurring_events_for('2008-03-01 12:00pm', '2008-06-26 12:00pm', 'UTC', NULL);"
        ]).should == [
          ['2008-04-25'],
          ['2008-06-25']
        ]
      end

      describe 'using a custom day of month' do
        it "should include the event on the specified days" do
          executing([
            "insert into events (id, starts_on, frequency) values (1, '2008-04-25', 'monthly');",
            "insert into event_recurrences (event_id, day) values (1, 28);",
            "insert into event_recurrences (event_id, day) values (1, 4);",
            "select starts_on from recurring_events_for('2008-04-01 12:00pm', '2008-05-25 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2008-04-28'],
            ['2008-05-04']
          ]
        end

        it "should put separation in between each recurrence" do
          executing([
            "insert into events (id, starts_on, frequency, separation) values (1, '2008-04-25', 'monthly', 2);",
            "insert into event_recurrences (event_id, day) values (1, 28);",
            "insert into event_recurrences (event_id, day) values (1, 4);",
            "select starts_on from recurring_events_for('2008-04-01 12:00pm', '2008-08-05 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2008-04-28'],
            ['2008-06-04'],
            ['2008-06-28'],
            ['2008-08-04']
          ]
        end
      end

      describe 'using a custom day of week in month' do
        it "should include the event on the specified days" do
          executing([
            "insert into events (id, starts_on, frequency) values (1, '2008-04-25', 'monthly');",
            "insert into event_recurrences (event_id, week, day) values (1, 2, 5);",
            "insert into event_recurrences (event_id, week, day) values (1, -2, 4);",
            "select starts_on from recurring_events_for('2008-04-01 12:00pm', '2008-05-25 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2008-05-09'],
            ['2008-05-22']
          ]
        end

        it "should put separation in between each recurrence" do
          executing([
            "insert into events (id, starts_on, frequency, separation) values (1, '2008-04-25', 'monthly', 2);",
            "insert into event_recurrences (event_id, week, day) values (1, 2, 5);",
            "insert into event_recurrences (event_id, week, day) values (1, -2, 4);",
            "select starts_on from recurring_events_for('2008-04-01 12:00pm', '2008-08-29 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2008-06-13'],
            ['2008-06-19'],
            ['2008-08-08'],
            ['2008-08-21']
          ]
        end

        it "should not include additional recurrences when the range starts after the event" do
          executing([
            "insert into events (id, starts_on, frequency, count) values (1, '2008-04-25', 'monthly', 5);",
            "insert into event_recurrences (event_id, week, day) values (1, 2, 5);",
            "insert into event_recurrences (event_id, week, day) values (1, -2, 4);",
            "select starts_on from recurring_events_for('2008-06-01 12:00pm', '2008-07-25 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-06-13'],
            ['2008-06-19']
          ]
        end
      end
    end

    describe 'yearly' do
      it "should include the event once for each year" do
        executing([
          "insert into events (starts_on, frequency) values ('2008-04-25', 'yearly');",
          "select starts_on from recurring_events_for('2007-04-01 12:00pm', '2010-04-24 12:00pm', 'UTC', NULL);"
        ]).should == [
          ['2008-04-25'],
          ['2009-04-25']
        ]
      end

      it "should put separation in between each recurrence" do
        executing([
          "insert into events (starts_on, frequency, separation) values ('2008-04-25', 'yearly', 2);",
          "select starts_on from recurring_events_for('2007-04-01 12:00pm', '2014-04-24 12:00pm', 'UTC', NULL);"
        ]).should == [
          ['2008-04-25'],
          ['2010-04-25'],
          ['2012-04-25']
        ]
      end

      describe 'using a custom month' do
        it "should include the event in the specified months" do
          executing([
            "insert into events (id, starts_on, frequency) values (1, '2008-04-25', 'yearly');",
            "insert into event_recurrences (event_id, month) values (1, 2);",
            "insert into event_recurrences (event_id, month) values (1, 7);",
            "select starts_on from recurring_events_for('2007-04-01 12:00pm', '2009-07-25 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2008-07-25'],
            ['2009-02-25'],
            ['2009-07-25']
          ]
        end
      end

      describe 'using a custom day of month' do
        it "should include the event on the specified days" do
          executing([
            "insert into events (id, starts_on, frequency) values (1, '2008-04-25', 'yearly');",
            "insert into event_recurrences (event_id, day) values (1, 28);",
            "insert into event_recurrences (event_id, day) values (1, 7);",
            "select starts_on from recurring_events_for('2007-04-01 12:00pm', '2009-04-28 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2008-04-28'],
            ['2009-04-07'],
            ['2009-04-28']
          ]
        end

        it "should put separation in between each recurrence" do
          executing([
            "insert into events (id, starts_on, frequency, separation) values (1, '2008-04-25', 'yearly', 2);",
            "insert into event_recurrences (event_id, day) values (1, 28);",
            "insert into event_recurrences (event_id, day) values (1, 7);",
            "select starts_on from recurring_events_for('2007-04-01 12:00pm', '2013-04-28 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2008-04-28'],
            ['2010-04-07'],
            ['2010-04-28'],
            ['2012-04-07'],
            ['2012-04-28']
          ]
        end
      end

      describe 'using a custom month and day of month' do
        it "should include the event on the specified days" do
          executing([
            "insert into events (id, starts_on, frequency) values (1, '2008-04-25', 'yearly');",
            "insert into event_recurrences (event_id, month, day) values (1, 2, 28);",
            "insert into event_recurrences (event_id, month, day) values (1, 2, 7);",
            "insert into event_recurrences (event_id, month, day) values (1, 7, 28);",
            "insert into event_recurrences (event_id, month, day) values (1, 7, 7);",
            "select starts_on from recurring_events_for('2007-04-01 12:00pm', '2009-07-07 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2008-07-07'],
            ['2008-07-28'],
            ['2009-02-07'],
            ['2009-02-28'],
            ['2009-07-07']
          ]
        end

        it "should put separation in between each recurrence" do
          executing([
            "insert into events (id, starts_on, frequency, separation) values (1, '2008-04-25', 'yearly', 2);",
            "insert into event_recurrences (event_id, month, day) values (1, 2, 28);",
            "insert into event_recurrences (event_id, month, day) values (1, 2, 7);",
            "insert into event_recurrences (event_id, month, day) values (1, 7, 28);",
            "insert into event_recurrences (event_id, month, day) values (1, 7, 7);",
            "select starts_on from recurring_events_for('2007-04-01 12:00pm', '2012-07-30 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2008-07-07'],
            ['2008-07-28'],
            ['2009-02-07'],
            ['2009-02-28'],
            ['2010-07-07'],
            ['2010-07-28'],
            ['2011-02-07'],
            ['2011-02-28'],
            ['2012-07-07'],
            ['2012-07-28']
          ]
        end
      end

      describe 'using a custom day of week in month' do
        it "should include the event on the specified days" do
          executing([
            "insert into events (id, starts_on, frequency) values (1, '2008-04-25', 'yearly');",
            "insert into event_recurrences (event_id, week, day) values (1, 2, 5);",
            "insert into event_recurrences (event_id, week, day) values (1, -2, 4);",
            "select starts_on from recurring_events_for('2007-04-01 12:00pm', '2009-04-25 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2009-04-10'],
            ['2009-04-23']
          ]
        end

        it "should put separation in between each recurrence" do
          executing([
            "insert into events (id, starts_on, frequency, separation) values (1, '2008-04-25', 'yearly', 2);",
            "insert into event_recurrences (event_id, week, day) values (1, 2, 5);",
            "insert into event_recurrences (event_id, week, day) values (1, -2, 4);",
            "select starts_on from recurring_events_for('2007-04-01 12:00pm', '2013-04-25 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2010-04-09'],
            ['2010-04-22'],
            ['2012-04-13'],
            ['2012-04-19']
          ]
        end
      end

      describe 'using a custom month and day of week in month' do
        it "should include the event on the specified days" do
          executing([
            "insert into events (id, starts_on, frequency) values (1, '2008-04-25', 'yearly');",
            "insert into event_recurrences (event_id, month, week, day) values (1, 2, 2, 5);",
            "insert into event_recurrences (event_id, month, week, day) values (1, 2, -2, 4);",
            "insert into event_recurrences (event_id, month, week, day) values (1, 7, 2, 5);",
            "insert into event_recurrences (event_id, month, week, day) values (1, 7, -2, 4);",
            "select starts_on from recurring_events_for('2007-04-01 12:00pm', '2009-07-10 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2008-07-11'],
            ['2008-07-24'],
            ['2009-02-13'],
            ['2009-02-19'],
            ['2009-07-10']
          ]
        end

        it "should put separation in between each recurrence" do
          executing([
            "insert into events (id, starts_on, frequency, separation) values (1, '2008-04-25', 'yearly', 2);",
            "insert into event_recurrences (event_id, month, week, day) values (1, 2, 2, 5);",
            "insert into event_recurrences (event_id, month, week, day) values (1, 2, -2, 4);",
            "insert into event_recurrences (event_id, month, week, day) values (1, 7, 2, 5);",
            "insert into event_recurrences (event_id, month, week, day) values (1, 7, -2, 4);",
            "select starts_on from recurring_events_for('2007-04-01 12:00pm', '2012-09-10 12:00pm', 'UTC', NULL);"
          ]).should == [
            ['2008-04-25'],
            ['2008-07-11'],
            ['2008-07-24'],
            ['2009-02-13'],
            ['2009-02-19'],
            ['2010-07-09'],
            ['2010-07-22'],
            ['2011-02-11'],
            ['2011-02-17'],
            ['2012-07-13'],
            ['2012-07-19']
          ]
        end
      end
    end
  end
end
