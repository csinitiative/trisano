require File.dirname(__FILE__) + '/../spec_helper'

describe HospitalsParticipation do
  before(:each) do
    @hp = HospitalsParticipation.create
  end

  it "should be valid for an admission date before an admission date" do
    @hp.update_attributes(:admission_date => Date.yesterday)
    @hp.update_attributes(:discharge_date => Date.today)
    @hp.should be_valid
    @hp.errors.on(:discharge_date).should be_nil 
  end

  it "should not allow a discharge date before an admission date" do
    @hp.update_attributes(:admission_date => Date.today)
    @hp.update_attributes(:discharge_date => Date.yesterday)
    @hp.errors.on(:discharge_date).should == "must be on or after " + Date.today.to_s
  end
  
  it "should be valid for an admission date in the past" do
    @hp.update_attributes(:admission_date => Date.yesterday)
    @hp.should be_valid
    @hp.errors.on(:admission_date).should be_nil 
  end
  
  it "should not allow an addmission date in the future" do
    @hp.update_attributes(:admission_date => Date.tomorrow)
    @hp.errors.on(:admission_date).should == "must be on or before " + Date.today.to_s
  end

  it "should be valid for a discharge date in the past" do
    @hp.update_attributes(:discharge_date => Date.yesterday)
    @hp.should be_valid
    @hp.errors.on(:discharge_date).should be_nil 
  end

  it "should not allow an discharge date in the future" do
    @hp.update_attributes(:discharge_date=> Date.tomorrow)
    @hp.errors.on(:discharge_date).should == "must be on or before " + Date.today.to_s
  end
  
end
