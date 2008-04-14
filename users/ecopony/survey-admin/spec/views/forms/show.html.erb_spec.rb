require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forms/show.html.erb" do
  include FormsHelper
  
  before(:each) do
    
    disease = mock_model(Disease)
    disease.stub!(:name).and_return("Tummy Ache")
    
    jurisdiction = mock_model(Jurisdiction)
    jurisdiction.stub!(:name).and_return("Bear River")
    
    @form = mock_model(Form)
    @form.stub!(:name).and_return("MyString")
    @form.stub!(:description).and_return("MyString")
    @form.stub!(:jurisdiction_id).and_return("1")
    @form.stub!(:disease_id).and_return("1")
    @form.stub!(:status).and_return("1")
    
    @form.stub!(:disease).and_return(disease)
    @form.stub!(:jurisdiction).and_return(jurisdiction)

    assigns[:form] = @form
  end

  it "should render attributes in <p>" do
    render "/forms/show.html.haml"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/1/)
  end
end

