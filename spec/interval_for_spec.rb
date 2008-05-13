require File.dirname(__FILE__) + '/helper'

describe 'interval_for' do
  it "should return '1 day' for 'daily'" do
    executing("select interval_for('daily');").should == [ ['1 day'] ]
  end

  it "should return '7 days' for 'weekly'" do
    executing("select interval_for('weekly');").should == [ ['7 days'] ]
  end

  it "should return '1 month' for 'monthly'" do
    executing("select interval_for('monthly');").should == [ ['1 mon'] ]
  end

  it "should return '1 year' for 'yearly'" do
    executing("select interval_for('yearly');").should == [ ['1 year'] ]
  end
end
