require File.dirname(__FILE__) + '/helper'

describe 'recurring_events_for' do
  it "should include events on a date inside of the range" do
    executing([
      "insert into events (date, frequency) values ('2008-04-25', 'once');",
      "select date from recurring_events_for('2008-04-24 12:00pm', '2008-04-26 12:00pm', '0');"
    ]).should == [
      ['2008-04-25']
    ]
  end

  it "should include events on the date of the start of the range" do
    executing([
      "insert into events (date, frequency) values ('2008-04-25', 'once');",
      "select date from recurring_events_for('2008-04-25 12:00pm', '2008-04-26 12:00pm', '0');"
    ]).should == [
      ['2008-04-25']
    ]
  end

  it "should include events on the date of the end of the range" do
    executing([
      "insert into events (date, frequency) values ('2008-04-25', 'once');",
      "select date from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 12:00pm', '0');"
    ]).should == [
      ['2008-04-25']
    ]
  end

  it "should include events on the date of the end of the range when the range ends at midnight" do
    executing([
      "insert into events (date, frequency) values ('2008-04-25', 'once');",
      "select date from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 12:00am', '0');"
    ]).should == [
      ['2008-04-25']
    ]
  end

  it "should not include events on a date outside of the range" do
    executing([
      "insert into events (date, frequency) values ('2008-04-23', 'once');",
      "select date from recurring_events_for('2008-04-24 12:00pm', '2008-04-26 12:00pm', '0');"
    ]).should == []
  end

  it "should include events starting and ending inside the range" do
    executing([
      "insert into events (starts_at, ends_at, frequency) values ('2008-04-25 12:00pm', '2008-04-26 12:00pm', 'once');",
      "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-27 12:00pm', '0');"
    ]).should == [
      ['2008-04-25 12:00:00', '2008-04-26 12:00:00']
    ]
  end

  it "should include events starting inside the range" do
    executing([
      "insert into events (starts_at, ends_at, frequency) values ('2008-04-25 12:00pm', '2008-04-27 12:00pm', 'once');",
      "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-26 12:00pm', '0');"
    ]).should == [
      ['2008-04-25 12:00:00', '2008-04-27 12:00:00']
    ]
  end

  it "should include events ending inside the range" do
    executing([
      "insert into events (starts_at, ends_at, frequency) values ('2008-04-24 12:00pm', '2008-04-26 12:00pm', 'once');",
      "select starts_at, ends_at from recurring_events_for('2008-04-25 12:00pm', '2008-04-27 12:00pm', '0');"
    ]).should == [
      ['2008-04-24 12:00:00', '2008-04-26 12:00:00']
    ]
  end

  it "should include events starting at the end of the range" do
    executing([
      "insert into events (starts_at, ends_at, frequency) values ('2008-04-25 12:00pm', '2008-04-26 12:00pm', 'once');",
      "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 12:00pm', '0');"
    ]).should == [
      ['2008-04-25 12:00:00', '2008-04-26 12:00:00']
    ]
  end

  it "should include events ending at the start of the range" do
    executing([
      "insert into events (starts_at, ends_at, frequency) values ('2008-04-25 12:00pm', '2008-04-26 12:00pm', 'once');",
      "select starts_at, ends_at from recurring_events_for('2008-04-26 12:00pm', '2008-04-27 12:00pm', '0');"
    ]).should == [
      ['2008-04-25 12:00:00', '2008-04-26 12:00:00']
    ]
  end

  it "should include events encapsulating the range" do
    executing([
      "insert into events (starts_at, ends_at, frequency) values ('2008-04-24 12:00pm', '2008-04-27 12:00pm', 'once');",
      "select starts_at, ends_at from recurring_events_for('2008-04-25 12:00pm', '2008-04-26 12:00pm', '0');"
    ]).should == [
      ['2008-04-24 12:00:00', '2008-04-27 12:00:00']
    ]
  end

  it "should not include events ending before the range start" do
    executing([
      "insert into events (starts_at, ends_at, frequency) values ('2008-04-24 12:00pm', '2008-04-25 12:00pm', 'once');",
      "select starts_at, ends_at from recurring_events_for('2008-04-26 12:00pm', '2008-04-27 12:00pm', '0');"
    ]).should == []
  end

  it "should not include events starting after the range end" do
    executing([
      "insert into events (starts_at, ends_at, frequency) values ('2008-04-26 12:00pm', '2008-04-27 12:00pm', 'once');",
      "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 12:00pm', '0');"
    ]).should == []
  end

  describe 'time zone offset' do
    it "should return starts_at and ends_at in UTC" do
      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-04-25 12:00pm', '2008-04-26 12:00pm', 'once');",
        "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-27 12:00pm', '-5 hours');"
      ]).should == [
        ['2008-04-25 12:00:00', '2008-04-26 12:00:00']
      ]
    end

    it "should take time zone into account when deciding whether or not a date is in the range" do
      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-04-25 12:00pm', '2008-04-26 12:00pm', 'once');",
        "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 7:00am', '-5 hours');"
      ]).should == [
        ['2008-04-25 12:00:00', '2008-04-26 12:00:00']
      ]

      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-04-25 12:00pm', '2008-04-26 12:00pm', 'once');",
        "select starts_at, ends_at from recurring_events_for('2008-04-26 7:00am', '2008-04-27 12:00pm', '-5 hours');"
      ]).should == [
        ['2008-04-25 12:00:00', '2008-04-26 12:00:00']
      ]

      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-04-25 12:00pm', '2008-04-26 12:00pm', 'once');",
        "select starts_at, ends_at from recurring_events_for('2008-04-26 8:00am', '2008-04-27 12:00pm', '-5 hours');"
      ]).should == []

      executing([
        "insert into events (starts_at, ends_at, frequency) values ('2008-04-25 12:00pm', '2008-04-26 12:00pm', 'once');",
        "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 4:00pm', '5 hours');"
      ]).should == []
    end
  end

  describe 'recurring' do
    describe 'time zone offset' do
      it "should return starts_at and ends_at in UTC" do
        executing([
          "insert into events (starts_at, ends_at, frequency) values ('2008-04-18 12:00pm', '2008-04-19 12:00pm', 'weekly');",
          "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-27 12:00pm', '-5 hours');"
        ]).should == [
          ['2008-04-25 12:00:00', '2008-04-26 12:00:00']
        ]
      end

      it "should take time zone into account when deciding whether or not a date is in the range" do
        executing([
          "insert into events (starts_at, ends_at, frequency) values ('2008-04-18 12:00pm', '2008-04-19 12:00pm', 'weekly');",
          "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 7:00am', '-5 hours');"
        ]).should == [
          ['2008-04-25 12:00:00', '2008-04-26 12:00:00']
        ]

        executing([
          "insert into events (starts_at, ends_at, frequency) values ('2008-04-18 12:00pm', '2008-04-19 12:00pm', 'weekly');",
          "select starts_at, ends_at from recurring_events_for('2008-04-26 7:00am', '2008-04-27 12:00pm', '-5 hours');"
        ]).should == [
          ['2008-04-25 12:00:00', '2008-04-26 12:00:00']
        ]

        executing([
          "insert into events (starts_at, ends_at, frequency) values ('2008-04-18 12:00pm', '2008-04-19 12:00pm', 'weekly');",
          "select starts_at, ends_at from recurring_events_for('2008-04-26 8:00am', '2008-04-27 12:00pm', '-5 hours');"
        ]).should == []

        executing([
          "insert into events (starts_at, ends_at, frequency) values ('2008-04-18 12:00pm', '2008-04-19 12:00pm', 'weekly');",
          "select starts_at, ends_at from recurring_events_for('2008-04-24 12:00pm', '2008-04-25 4:00pm', '5 hours');"
        ]).should == []
      end
    end

    it "should only include events before or on the until date" do
      executing([
        "insert into events (date, frequency, until) values ('2008-04-25', 'daily', '2008-04-27');",
        "select date from recurring_events_for('2008-04-24 12:00pm', '2008-04-29 12:00pm', '0');"
      ]).should == [
        ['2008-04-25'],
        ['2008-04-26'],
        ['2008-04-27']
      ]
    end

    it "should only include events for count recurrences" do
      executing([
        "insert into events (date, frequency, count) values ('2008-04-25', 'daily', 3);",
        "select date from recurring_events_for('2008-04-24 12:00pm', '2008-04-29 12:00pm', '0');"
      ]).should == [
        ['2008-04-25'],
        ['2008-04-26'],
        ['2008-04-27']
      ]
    end

    describe 'cancellations' do
      it "should not include cancelled recurrences" do
        executing([
          "insert into events (id, date, frequency) values (1, '2008-04-25', 'daily');",
          "insert into event_cancellations (event_id, date) values (1, '2008-04-26')",
          "select date from recurring_events_for('2008-04-26 12:00pm', '2008-04-26 1:00pm', '0');"
        ]).should == []
      end

      it "should still include uncancelled recurrences" do
        executing([
          "insert into events (id, date, frequency) values (1, '2008-04-25', 'daily');",
          "insert into event_cancellations (event_id, date) values (1, '2008-04-26')",
          "select date from recurring_events_for('2008-04-25 12:00pm', '2008-04-27 12:00pm', '0');"
        ]).should == [
          ['2008-04-25'],
          ['2008-04-27']
        ]
      end

      it "should still have recurrences if the first was cancelled" do
        executing([
          "insert into events (id, date, frequency) values (1, '2008-04-25', 'daily');",
          "insert into event_cancellations (event_id, date) values (1, '2008-04-25')",
          "select date from recurring_events_for('2008-04-26 12:00pm', '2008-04-26 1:00pm', '0');"
        ]).should == [
          ['2008-04-26']
        ]
      end

      it "should not include additional recurrences for events restricted by count" do
        executing([
          "insert into events (id, date, frequency, count) values (1, '2008-04-25', 'daily', 3);",
          "insert into event_cancellations (event_id, date) values (1, '2008-04-26')",
          "select date from recurring_events_for('2008-04-25 12:00pm', '2008-04-28 12:00pm', '0');"
        ]).should == [
          ['2008-04-25'],
          ['2008-04-27']
        ]
      end
    end

    describe 'daily' do
      it "should include the event once for each day" do
        executing([
          "insert into events (date, frequency) values ('2008-04-25', 'daily');",
          "select date from recurring_events_for('2008-04-01 12:00pm', '2008-04-26 1:00pm', '0');"
        ]).should == [
          ['2008-04-25'],
          ['2008-04-26']
        ]
      end
    end

    describe 'weekly' do
      it "should include the event once for each week" do
        executing([
          "insert into events (date, frequency) values ('2008-04-25', 'weekly');",
          "select date from recurring_events_for('2008-04-01 12:00pm', '2008-05-08 12:00pm', '0');"
        ]).should == [
          ['2008-04-25'],
          ['2008-05-02']
        ]
      end

      describe 'using a custom day of week' do
        it "should include the event once for each occurrence" do
          executing([
            "insert into events (id, date, frequency) values (1, '2008-04-25', 'weekly');",
            "insert into event_recurrences (event_id, day) values (1, 2);",
            "insert into event_recurrences (event_id, day) values (1, 4);",
            "select distinct date from recurring_events_for('2008-04-01 12:00pm', '2008-05-02 12:00pm', '0');"
          ]).should == [
            ['2008-04-25'],
            ['2008-04-29'],
            ['2008-05-01']
          ]
        end
      end
    end

    describe 'monthly' do
      it "should include the event once for each month" do
        executing([
          "insert into events (date, frequency) values ('2008-04-25', 'monthly');",
          "select date from recurring_events_for('2008-03-01 12:00pm', '2008-06-24 12:00pm', '0');"
        ]).should == [
          ['2008-04-25'],
          ['2008-05-25']
        ]
      end

      describe 'using a custom day of month' do
        it "should include the event on the specified days" do
          executing([
            "insert into events (id, date, frequency) values (1, '2008-04-25', 'monthly');",
            "insert into event_recurrences (event_id, day) values (1, 28);",
            "insert into event_recurrences (event_id, day) values (1, 4);",
            "select distinct date from recurring_events_for('2008-04-01 12:00pm', '2008-05-25 12:00pm', '0');"
          ]).should == [
            ['2008-04-25'],
            ['2008-04-28'],
            ['2008-05-04']
          ]
        end

        it "should include count recurrences" do
          executing([
            "insert into events (id, date, frequency, count) values (1, '2008-04-25', 'monthly', 3);",
            "insert into event_recurrences (event_id, day) values (1, 28);",
            "insert into event_recurrences (event_id, day) values (1, 4);",
            "select distinct date from recurring_events_for('2008-04-01 12:00pm', '2008-06-25 12:00pm', '0');"
          ]).should == [
            ['2008-04-25'],
            ['2008-04-28'],
            ['2008-05-04']
          ]
        end
      end

      describe 'using a custom day of week in month' do
        it "should include the event on the specified days" do
          executing([
            "insert into events (id, date, frequency) values (1, '2008-04-25', 'monthly');",
            "insert into event_recurrences (event_id, week, day) values (1, 2, 5);",
            "insert into event_recurrences (event_id, week, day) values (1, -2, 4);",
            "select distinct date from recurring_events_for('2008-04-01 12:00pm', '2008-05-25 12:00pm', '0');"
          ]).should == [
            ['2008-04-25'],
            ['2008-05-09'],
            ['2008-05-22']
          ]
        end

        it "should include count recurrences" do
          executing([
            "insert into events (id, date, frequency, count) values (1, '2008-04-25', 'monthly', 5);",
            "insert into event_recurrences (event_id, week, day) values (1, 2, 5);",
            "insert into event_recurrences (event_id, week, day) values (1, -2, 4);",
            "select distinct date from recurring_events_for('2008-04-01 12:00pm', '2008-07-25 12:00pm', '0');"
          ]).should == [
            ['2008-04-25'],
            ['2008-05-09'],
            ['2008-05-22'],
            ['2008-06-13'],
            ['2008-06-19']
          ]
        end
      end
    end

    describe 'yearly' do
      it "should include the event once for each year" do
        executing([
          "insert into events (date, frequency) values ('2008-04-25', 'yearly');",
          "select date from recurring_events_for('2007-04-01 12:00pm', '2010-04-24 12:00pm', '0');"
        ]).should == [
          ['2008-04-25'],
          ['2009-04-25']
        ]
      end

      describe 'using a custom month' do
        it "should include the event in the specified months" do
          executing([
            "insert into events (id, date, frequency) values (1, '2008-04-25', 'yearly');",
            "insert into event_recurrences (event_id, month) values (1, 2);",
            "insert into event_recurrences (event_id, month) values (1, 7);",
            "select distinct date from recurring_events_for('2007-04-01 12:00pm', '2009-07-25 12:00pm', '0');"
          ]).should == [
            ['2008-04-25'],
            ['2008-07-25'],
            ['2009-02-25'],
            ['2009-07-25']
          ]
        end

        it "should include count recurrences" do
          executing([
            "insert into events (id, date, frequency, count) values (1, '2008-04-25', 'yearly', 4);",
            "insert into event_recurrences (event_id, month) values (1, 2);",
            "insert into event_recurrences (event_id, month) values (1, 7);",
            "select distinct date from recurring_events_for('2007-04-01 12:00pm', '2010-07-25 12:00pm', '0');"
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
            "insert into events (id, date, frequency) values (1, '2008-04-25', 'yearly');",
            "insert into event_recurrences (event_id, day) values (1, 28);",
            "insert into event_recurrences (event_id, day) values (1, 7);",
            "select distinct date from recurring_events_for('2007-04-01 12:00pm', '2009-04-28 12:00pm', '0');"
          ]).should == [
            ['2008-04-25'],
            ['2008-04-28'],
            ['2009-04-07'],
            ['2009-04-28']
          ]
        end

        it "should include count recurrences" do
          executing([
            "insert into events (id, date, frequency, count) values (1, '2008-04-25', 'yearly', 4);",
            "insert into event_recurrences (event_id, day) values (1, 28);",
            "insert into event_recurrences (event_id, day) values (1, 7);",
            "select distinct date from recurring_events_for('2007-04-01 12:00pm', '2010-04-28 12:00pm', '0');"
          ]).should == [
            ['2008-04-25'],
            ['2008-04-28'],
            ['2009-04-07'],
            ['2009-04-28']
          ]
        end
      end

      describe 'using a custom month and day of month' do
        it "should include the event on the specified days" do
          executing([
            "insert into events (id, date, frequency) values (1, '2008-04-25', 'yearly');",
            "insert into event_recurrences (event_id, month, day) values (1, 2, 28);",
            "insert into event_recurrences (event_id, month, day) values (1, 2, 7);",
            "insert into event_recurrences (event_id, month, day) values (1, 7, 28);",
            "insert into event_recurrences (event_id, month, day) values (1, 7, 7);",
            "select distinct date from recurring_events_for('2007-04-01 12:00pm', '2009-07-07 12:00pm', '0');"
          ]).should == [
            ['2008-04-25'],
            ['2008-07-07'],
            ['2008-07-28'],
            ['2009-02-07'],
            ['2009-02-28'],
            ['2009-07-07']
          ]
        end

        it "should include count recurrences" do
          executing([
            "insert into events (id, date, frequency, count) values (1, '2008-04-25', 'yearly', 6);",
            "insert into event_recurrences (event_id, month, day) values (1, 2, 28);",
            "insert into event_recurrences (event_id, month, day) values (1, 2, 7);",
            "insert into event_recurrences (event_id, month, day) values (1, 7, 28);",
            "insert into event_recurrences (event_id, month, day) values (1, 7, 7);",
            "select distinct date from recurring_events_for('2007-04-01 12:00pm', '2010-07-07 12:00pm', '0');"
          ]).should == [
            ['2008-04-25'],
            ['2008-07-07'],
            ['2008-07-28'],
            ['2009-02-07'],
            ['2009-02-28'],
            ['2009-07-07']
          ]
        end
      end

      describe 'using a custom day of week in month' do
        it "should include the event on the specified days" do
          executing([
            "insert into events (id, date, frequency) values (1, '2008-04-25', 'yearly');",
            "insert into event_recurrences (event_id, week, day) values (1, 2, 5);",
            "insert into event_recurrences (event_id, week, day) values (1, -2, 4);",
            "select distinct date from recurring_events_for('2007-04-01 12:00pm', '2009-04-25 12:00pm', '0');"
          ]).should == [
            ['2008-04-25'],
            ['2009-04-10'],
            ['2009-04-23']
          ]
        end

        it "should include count recurrences" do
          executing([
            "insert into events (id, date, frequency, count) values (1, '2008-05-25', 'yearly', 5);",
            "insert into event_recurrences (event_id, week, day) values (1, 2, 5);",
            "insert into event_recurrences (event_id, week, day) values (1, -2, 4);",
            "select distinct date from recurring_events_for('2007-04-01 12:00pm', '2011-06-25 12:00pm', '0');"
          ]).should == [
            ['2008-05-25'],
            ['2009-05-08'],
            ['2009-05-21'],
            ['2010-05-14'],
            ['2010-05-20']
          ]
        end
      end

      describe 'using a custom month and day of week in month' do
        it "should include the event on the specified days" do
          executing([
            "insert into events (id, date, frequency) values (1, '2008-04-25', 'yearly');",
            "insert into event_recurrences (event_id, month, week, day) values (1, 2, 2, 5);",
            "insert into event_recurrences (event_id, month, week, day) values (1, 2, -2, 4);",
            "insert into event_recurrences (event_id, month, week, day) values (1, 7, 2, 5);",
            "insert into event_recurrences (event_id, month, week, day) values (1, 7, -2, 4);",
            "select distinct date from recurring_events_for('2007-04-01 12:00pm', '2009-07-10 12:00pm', '0');"
          ]).should == [
            ['2008-04-25'],
            ['2008-07-11'],
            ['2008-07-24'],
            ['2009-02-13'],
            ['2009-02-19'],
            ['2009-07-10']
          ]
        end

        it "should include count recurrences" do
          executing([
            "insert into events (id, date, frequency, count) values (1, '2009-04-25', 'yearly', 6);",
            "insert into event_recurrences (event_id, month, week, day) values (1, 2, 2, 5);",
            "insert into event_recurrences (event_id, month, week, day) values (1, 2, -2, 4);",
            "insert into event_recurrences (event_id, month, week, day) values (1, 5, 2, 5);",
            "insert into event_recurrences (event_id, month, week, day) values (1, 5, -2, 4);",
            "select distinct date from recurring_events_for('2007-04-01 12:00pm', '2010-07-10 12:00pm', '0');"
          ]).should == [
            ['2009-04-25'],
            ['2009-05-08'],
            ['2009-05-21'],
            ['2010-02-12'],
            ['2010-02-18'],
            ['2010-05-14']
          ]
        end
      end
    end
  end
end
