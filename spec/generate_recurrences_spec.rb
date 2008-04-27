require File.dirname(__FILE__) + '/helper'

describe 'generate_recurrences' do
  it "should return dates inside of the range" do
    executing("select * from generate_recurrences('normal', '1 day', '2008-04-20', '2008-04-25', '2008-04-29');").should == [
      ['2008-04-25'],
      ['2008-04-26'],
      ['2008-04-27'],
      ['2008-04-28'],
      ['2008-04-29']
    ]
  end

  it "should only include dates on the frequency specified" do
    executing("select * from generate_recurrences('normal', '7 days', '2008-04-01', '2008-04-01', '2008-04-29');").should == [
      ['2008-04-01'],
      ['2008-04-08'],
      ['2008-04-15'],
      ['2008-04-22'],
      ['2008-04-29']
    ]
  end

  it "should not include dates before the original_date" do
    executing("select * from generate_recurrences('normal', '1 day', '2008-04-25', '2008-04-20', '2008-04-29');").should == [
      ['2008-04-25'],
      ['2008-04-26'],
      ['2008-04-27'],
      ['2008-04-28'],
      ['2008-04-29']
    ]
  end

  it "should return dates whole intervals away from original_date even if start_date isn't" do
    executing("select * from generate_recurrences('normal', '7 days', '2008-04-01', '2008-04-04', '2008-04-29');").should == [
      ['2008-04-08'],
      ['2008-04-15'],
      ['2008-04-22'],
      ['2008-04-29']
    ]
  end

  describe 'by week and day of week' do
    it "should include the dates on the particular positive offset week's day of week" do
      executing("select * from generate_recurrences('positive_week_dow', '28 days', '2008-04-15', '2008-04-15', '2008-06-17');").should == [
        ['2008-04-15'],
        ['2008-05-20'],
        ['2008-06-17']
      ]
    end

    it "should include the dates on the particular negative offset week's day of week" do
      executing("select * from generate_recurrences('negative_week_dow', '28 days', '2008-04-17', '2008-04-17', '2008-06-19');").should == [
        ['2008-04-17'],
        ['2008-05-22'],
        ['2008-06-19']
      ]
    end

    it "should not get stuck in an infinite loop when the duration does not put us in the next month" do
      executing("select * from generate_recurrences('positive_week_dow', '28 days', '2008-04-01', '2008-04-01', '2008-06-03');").should == [
        ['2008-04-01'],
        ['2008-05-06'],
        ['2008-06-03']
      ]
    end

    it "should not put the next recurrence in the wrong month if the duration does not put us in the right month next year" do
      executing("select * from generate_recurrences('positive_week_dow', '364 days', '2008-04-01', '2008-04-01', '2010-04-06');").should == [
        ['2008-04-01'],
        ['2009-04-07'],
        ['2010-04-06']
      ]
    end

    it "should not skip the first recurrence if the ceiled intervals to range_start puts us in the next month" do
      executing("select * from generate_recurrences('positive_week_dow', '28 days', '2008-05-08', '2008-06-10', '2008-08-14');").should == [
        ['2008-06-12'],
        ['2008-07-10'],
        ['2008-08-14']
      ]
    end

    it "should not include recurrences before the original_date" do
      executing("select * from generate_recurrences('positive_week_dow', '28 days', '2008-05-01', '2008-04-01', '2008-06-05');").should == [
        ['2008-05-01'],
        ['2008-06-05']
      ]
    end
  end
end
