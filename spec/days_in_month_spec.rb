require File.dirname(__FILE__) + '/helper'

describe 'days_in_month' do
  it "should return the number of days in the month of the given date" do
    executing("select days_in_month('2008-05-12');").should == [ ['31'] ]
    executing("select days_in_month('2008-06-12');").should == [ ['30'] ]
    executing("select days_in_month('2008-02-12');").should == [ ['29'] ]
    executing("select days_in_month('2009-02-12');").should == [ ['28'] ]
  end

  it "should return the correct number of days given a date on the last day of the month when the following month has fewer days" do
    executing("select days_in_month('2008-05-31');").should == [ ['31'] ]
    executing("select days_in_month('2008-01-31');").should == [ ['31'] ]
    executing("select days_in_month('2008-01-30');").should == [ ['31'] ]
  end
end
