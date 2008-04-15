require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sections/edit.html.erb" do
  include SectionsHelper
  
  before do
    @section = mock_model(Section)
    @section.stub!(:name).and_return("MyString")
    @section.stub!(:form_id).and_return("1")
    assigns[:section] = @section
  end

  it "should render edit form" do
    render "/sections/edit.html.haml"
    
    response.should have_tag("form[action=#{section_path(@section)}][method=post]") do
      with_tag('input#section_name[name=?]', "section[name]")
    end
  end
end


