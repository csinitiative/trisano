require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forms/index.html.erb" do
  include FormsHelper
  
  before(:each) do
    
    disease = mock_model(Disease)
    disease.stub!(:name).and_return("Tummy Ache")
    
    jurisdiction = mock_model(Jurisdiction)
    jurisdiction.stub!(:name).and_return("Bear River")
    
    form_98 = mock_model(Form)
    form_98.should_receive(:name).and_return("MyString")  
    
    form_98.stub!(:disease).and_return(disease)
    form_98.stub!(:jurisdiction).and_return(jurisdiction)

    form_99 = mock_model(Form)
    form_99.should_receive(:name).and_return("MyString")
    
    form_99.stub!(:disease).and_return(disease)
    form_99.stub!(:jurisdiction).and_return(jurisdiction)

    assigns[:forms] = [form_98, form_99]
  end

  it "should render list of forms" do
    render "/forms/index.html.haml"
  end
end

