require File.dirname(__FILE__) + '/../spec_helper'
require 'ostruct'
require RAILS_ROOT + '/app/helpers/application_helper'


describe SearchHelper do

  include ApplicationHelper

  def header_string
    %w(record_number last_name first_name middle_name birth_date age disease_name onset_date gender jurisdiction_name entered_on investigation_status city county).join(',')
  end

  def mock_cmr
    @expected_date = 10.years.ago
    OpenStruct.new :birth_date => @expected_date
  end

  it "should return zero results message when nil" do
    render_csv(nil).should == "Your search returned no results"    
  end
  
  it "should return zero results message when empty" do
    render_csv([]).should == "Your search returned no results"
  end

  it "should return header" do
    render_csv([mock_cmr]).split("\n").first.should == header_string
  end
  
  it "should return the correct number of fields" do
    render_csv([mock_cmr]).split("\n")[1].should == ",,,,#{@expected_date},10,,,,,,,,"
  end

end
