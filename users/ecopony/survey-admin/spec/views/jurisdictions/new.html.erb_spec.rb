require File.dirname(__FILE__) + '/../../spec_helper'

describe "/jurisdictions/new.html.erb" do
  include JurisdictionsHelper
  
  before(:each) do
    @jurisdiction = mock_model(Jurisdiction)
    @jurisdiction.stub!(:new_record?).and_return(true)
    @jurisdiction.stub!(:name).and_return("MyString")
    assigns[:jurisdiction] = @jurisdiction
  end

  it "should render new form" do
    render "/jurisdictions/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", jurisdictions_path) do
      with_tag("input#jurisdiction_name[name=?]", "jurisdiction[name]")
    end
  end
end


