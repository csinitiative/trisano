require File.dirname(__FILE__) + '/../../spec_helper'

describe "/jurisdictions/edit.html.erb" do
  include JurisdictionsHelper
  
  before do
    @jurisdiction = mock_model(Jurisdiction)
    @jurisdiction.stub!(:name).and_return("MyString")
    assigns[:jurisdiction] = @jurisdiction
  end

  it "should render edit form" do
    render "/jurisdictions/edit.html.haml"
    
    response.should have_tag("form[action=#{jurisdiction_path(@jurisdiction)}][method=post]") do
      with_tag('input#jurisdiction_name[name=?]', "jurisdiction[name]")
    end
  end
end


