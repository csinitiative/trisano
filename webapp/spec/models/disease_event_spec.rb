require File.dirname(__FILE__) + '/../spec_helper'

describe DiseaseEvent do

  before(:each) do
    @de = DiseaseEvent.create
  end

  it "should be valid for date diagnosed after onset date" do
    @de.update_attributes(:disease_onset_date => Date.yesterday)
    @de.update_attributes(:date_diagnosed => Date.today)
    @de.should be_valid
    @de.errors.on(:date_diagnosed).should be_nil
  end

  it "should not allow date diagnosed to occur before onset date" do
    @de.update_attributes(:disease_onset_date => Date.today)
    @de.update_attributes(:date_diagnosed => Date.yesterday)
    @de.errors.on(:date_diagnosed).should == "must be on or after " + Date.today.to_s
  end

  it "should be valid for an onset date in the past" do
    @de.update_attributes(:disease_onset_date => Date.yesterday)
    @de.should be_valid
    @de.errors.on(:disease_onset_date).should be_nil
  end
 
  it "should not allow an onset date in the future" do
    @de.update_attributes(:disease_onset_date => Date.tomorrow)
    @de.errors.on(:disease_onset_date).should == "must be on or before " + Date.today.to_s
  end

  it "should be valid for a diagnosed date in the past" do
    @de.update_attributes(:date_diagnosed => Date.yesterday)
    @de.should be_valid
    @de.errors.on(:date_diagnosed).should be_nil
  end

  it "should not allow an diagnosed date in the future" do
    @de.update_attributes(:date_diagnosed => Date.tomorrow)
    @de.errors.on(:date_diagnosed).should == "must be on or before " + Date.today.to_s
  end

end
