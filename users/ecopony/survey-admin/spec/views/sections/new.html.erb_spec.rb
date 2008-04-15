require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sections/new.html.erb" do
  include SectionsHelper
  
  before(:each) do
    @section = mock_model(Section)
    @section.stub!(:new_record?).and_return(true)
    @section.stub!(:name).and_return("MyString")
    @section.stub!(:form_id).and_return("1")
    assigns[:section] = @section
  end

  it "should render new form" do
    render "/sections/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", sections_path) do
      with_tag("input#section_name[name=?]", "section[name]")
    end
  end
end


