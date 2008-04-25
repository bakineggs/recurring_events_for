require File.dirname(__FILE__) + '/helper'

describe 'intervals_between' do
  it "should return the number of days between two dates" do
    executing("select intervals_between('2008-04-25', '2008-04-26', '1 day');").should == [ ['1'] ]
  end

  it "should correctly calculate the days when wrapping a month" do
    executing("select intervals_between('2008-04-29', '2008-05-02', '1 day');").should == [ ['3'] ]
  end

  it "should be able to use an arbitrary number of days for the interval" do
    executing("select intervals_between('2008-04-20', '2008-04-25', '5 days');").should == [ ['1'] ]
  end

  it "should return a fraction of the interval for spans that aren't multiples of the interval" do
    executing("select intervals_between('2008-04-20', '2008-04-25', '4 days');").should == [ ['1.25'] ]
  end

  it "should accept months for the interval" do
    executing("select intervals_between('2008-04-25', '2008-08-25', '2 months');").should == [ ['2'] ]
  end

  it "should return fractions of months" do
    executing("select intervals_between('2008-03-10', '2008-04-25', '1 month');").should == [ ['1.5'] ]
  end

  it "should accept years for the interval" do
    executing("select intervals_between('2008-04-25', '2010-04-25', '1 year');").should == [ ['2'] ]
  end

  it "should return fractions of years" do
    executing("select intervals_between('2008-04-25', '2009-07-07', '1 year');").should == [ ['1.2'] ]
  end
end
