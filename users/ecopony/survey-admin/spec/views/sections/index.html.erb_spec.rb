require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sections/index.html.erb" do
  include SectionsHelper
  
  before(:each) do
    
    form = mock_model(Form)
    form.stub!(:name).and_return("Tummy Ache Demographics")
    
    section_98 = mock_model(Section)
    section_98.should_receive(:name).and_return("MyString")
    section_98.stub!(:form).and_return(form)
    
    section_99 = mock_model(Section)
    section_99.should_receive(:name).and_return("MyString")
    section_99.stub!(:form).and_return(form)

    assigns[:sections] = [section_98, section_99]
  end

  it "should render list of sections" do
    render "/sections/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
  end
end

