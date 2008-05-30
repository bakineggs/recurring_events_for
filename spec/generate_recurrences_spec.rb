require File.dirname(__FILE__) + '/helper'

describe 'generate_recurrences' do
  it "should return dates inside of the range" do
    executing("select * from generate_recurrences('1 day', '2008-04-25', '2008-04-29', NULL, NULL, NULL);").should == [
      ['2008-04-25'],
      ['2008-04-26'],
      ['2008-04-27'],
      ['2008-04-28'],
      ['2008-04-29']
    ]
  end

  it "should only include dates on the frequency specified" do
    executing("select * from generate_recurrences('7 days', '2008-04-01', '2008-04-29', NULL, NULL, NULL);").should == [
      ['2008-04-01'],
      ['2008-04-08'],
      ['2008-04-15'],
      ['2008-04-22'],
      ['2008-04-29']
    ]
  end

  it "should return dates on the correct day of month when the start is the end of the month" do
    executing("select * from generate_recurrences('1 month', '2008-05-31', '2008-07-31', NULL, NULL, NULL);").should == [
      ['2008-05-31'],
      ['2008-06-30'],
      ['2008-07-31']
    ]
  end

  describe 'by day of week' do
    it "should return dates on the requested day of week" do
      executing("select * from generate_recurrences('7 days', '2008-05-12', '2008-05-23', NULL, NULL, 4);").should == [
        ['2008-05-15'],
        ['2008-05-22']
      ]
    end
  end

  describe 'by month' do
    it "should return the day in the requested month" do
      executing("select * from generate_recurrences('1 year', '2008-04-15', '2010-06-15', 5, NULL, NULL);").should == [
        ['2008-05-15'],
        ['2009-05-15'],
        ['2010-05-15']
      ]
    end
  end

  describe 'by day of month' do
    it "should return the dates on the requested day of month" do
      executing("select * from generate_recurrences('1 month', '2008-04-01', '2008-06-30', NULL, NULL, 15);").should == [
        ['2008-04-15'],
        ['2008-05-15'],
        ['2008-06-15']
      ]
    end

    describe 'by month' do
      it "should return the correct day of month in the correct month" do
        executing("select * from generate_recurrences('1 year', '2008-04-01', '2010-06-30', 5, NULL, 15);").should == [
          ['2008-05-15'],
          ['2009-05-15'],
          ['2010-05-15']
        ]
      end
    end
  end

  describe 'by week and day of week' do
    it "should include the dates on the particular positive offset week's day of week" do
      executing("select * from generate_recurrences('1 month', '2008-04-01', '2008-06-30', NULL, 3, 2);").should == [
        ['2008-04-15'],
        ['2008-05-20'],
        ['2008-06-17']
      ]
    end

    it "should include the dates on the particular negative offset week's day of week" do
      executing("select * from generate_recurrences('1 month', '2008-04-01', '2008-06-30', NULL, -2, 4);").should == [
        ['2008-04-17'],
        ['2008-05-22'],
        ['2008-06-19']
      ]
    end

    it "should not skip a month if offsetting to the correct day of week puts us in the wrong month" do
      executing("select * from generate_recurrences('1 month', '2008-05-01', '2008-07-31', NULL, -1, 5);").should == [
        ['2008-05-30'],
        ['2008-06-27'],
        ['2008-07-25']
      ]
    end

    it "should return the correct week when the event should repeat on the last day of the month and the next month has fewer days" do
      executing("select * from generate_recurrences('1 month', '2008-04-26', '2008-06-28', NULL, -1, 6);").should == [
        ['2008-04-26'],
        ['2008-05-31'],
        ['2008-06-28']
      ]
    end

    describe 'by month' do
      it "should return the dates in the correct month" do
        executing("select * from generate_recurrences('1 year', '2008-04-01', '2010-06-30', 5, 3, 2);").should == [
          ['2008-05-20'],
          ['2009-05-19'],
          ['2010-05-18']
        ]
      end
    end
  end
end
