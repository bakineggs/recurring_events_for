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

  it "should return '28 days' for 'monthly_by_week_dow'" do
    executing("select interval_for('monthly_by_week_dow');").should == [ ['28 days'] ]
  end

  it "should return '1 year' for 'yearly'" do
    executing("select interval_for('yearly');").should == [ ['1 year'] ]
  end

  it "should return '364 days' for 'yearly_by_week_dow'" do
    executing("select interval_for('yearly_by_week_dow');").should == [ ['364 days'] ]
  end
end
