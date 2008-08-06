require File.dirname(__FILE__) + '/../spec_helper'

describe LabResult do
  before(:each) do
    @lab_result = LabResult.new
    @lab_result.lab_result_text = "Positive"
  end

  it "should not be valid when empty" do
    @lab_result.lab_result_text = nil
    @lab_result.should_not be_valid
  end

  it "should be valid with only result text" do
    @lab_result.should be_valid
  end

  it "should be valid with just a collection date" do
    @lab_result.collection_date = Date.parse("06/15/08")
    @lab_result.should be_valid
  end

  it "should be valid with just a lab test date" do
    @lab_result.lab_test_date = Date.parse("06/15/08")
    @lab_result.should be_valid
  end

  it "should be valid with both a collection date and lab test date" do
    @lab_result.collection_date = Date.parse("06/15/08")
    @lab_result.lab_test_date = Date.parse("06/16/08")
    @lab_result.should be_valid
  end

  it "should not be valid if test date precedes collection date" do
    @lab_result.collection_date = Date.parse("06/16/08")
    @lab_result.lab_test_date = Date.parse("06/15/08")
    @lab_result.should_not be_valid
  end
end
