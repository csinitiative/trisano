require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forms/new.html.haml" do
  include FormsHelper
  
  before(:each) do
    @form = mock_model(Form)
    @form.stub!(:new_record?).and_return(true)
    @form.stub!(:name).and_return("MyString")
    @form.stub!(:description).and_return("MyString")
    @form.stub!(:jurisdiction_id).and_return(nil)

    @disease_1 = mock_model(Disease)
    @disease_1.stub!(:disease_name).and_return("Anthrax")
    @disease_2 = mock_model(Disease)
    @disease_2.stub!(:disease_name).and_return("Tetanus")
    Disease.should_receive(:find).and_return([@disease_1, @disease_2])

    @form.stub!(:diseases).and_return([@disease_1])

    @jurisdiction_1 = mock_model(Place)
    @jurisdiction_1.stub!(:name).and_return("Summit")
    @jurisdiction_1.stub!(:entity_id).and_return("1")
    @jurisdiction_2 = mock_model(Place)
    @jurisdiction_2.stub!(:name).and_return("Davis")
    @jurisdiction_2.stub!(:entity_id).and_return("2")
    Place.should_receive(:jurisdictions).and_return([@jurisdiction_1, @jurisdiction_2])

    assigns[:form] = @form
  end

  it "should render new form" do
    render "/forms/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", forms_path) do
      with_tag("input#form_name[name=?]", "form[name]")
      with_tag("input#form_description[name=?]", "form[description]")
      with_tag("input[type=checkbox]", 2) 
      with_tag("select#form_jurisdiction_id[name=?]", "form[jurisdiction_id]") do
        with_tag("option", "Summit")
        with_tag("option", "Davis")
      end
    end

    response.should have_text(/Anthrax/)
    response.should have_text(/Tetanus/)
  end
end
