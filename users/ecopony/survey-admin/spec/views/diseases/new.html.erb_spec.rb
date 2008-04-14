require File.dirname(__FILE__) + '/../../spec_helper'

describe "/diseases/new.html.erb" do
  include DiseasesHelper
  
  before(:each) do
    @disease = mock_model(Disease)
    @disease.stub!(:new_record?).and_return(true)
    @disease.stub!(:name).and_return("MyString")
    assigns[:disease] = @disease
  end

  it "should render new form" do
    render "/diseases/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", diseases_path) do
      with_tag("input#disease_name[name=?]", "disease[name]")
    end
  end
end


