require File.dirname(__FILE__) + '/../../spec_helper'

# We should merge edit and new commonalities
describe "/forms/edit.html.haml" do
  include FormsHelper
  
  before do
    @form = mock_model(Form)
    @form.stub!(:name).and_return("MyString")
    @form.stub!(:description).and_return("MyString")
    @form.stub!(:disease_id).and_return(1)
    @form.stub!(:jurisdiction_id).and_return(2)

    @disease_1 = mock_model(Disease)
    @disease_1.stub!(:disease_name).and_return("Anthrax")
    @disease_2 = mock_model(Disease)
    @disease_2.stub!(:disease_name).and_return("Tetanus")
    Disease.should_receive(:find).and_return([@disease_1, @disease_2])

    @jurisdiction_1 = mock_model(Place)
    @jurisdiction_1.stub!(:name).and_return("Summit")
    @jurisdiction_1.stub!(:entity_id).and_return("1")
    @jurisdiction_2 = mock_model(Place)
    @jurisdiction_2.stub!(:name).and_return("Davis")
    @jurisdiction_2.stub!(:entity_id).and_return("2")
    Place.should_receive(:jurisdictions).and_return([@jurisdiction_1, @jurisdiction_2])

    assigns[:form] = @form
  end

  it "should render edit form" do
    render "/forms/edit.html.haml"
    
    response.should have_tag("form[action=#{form_path(@form)}][method=post]") do
      with_tag('input#form_name[name=?]', "form[name]")
      with_tag('input#form_description[name=?]', "form[description]")
      with_tag("select#form_disease_id[name=?]", "form[disease_id]") do
        # How to test which one's selected?
        with_tag("option", "Anthrax")
        with_tag("option", "Tetanus")
      end
      with_tag("select#form_jurisdiction_id[name=?]", "form[jurisdiction_id]") do
        with_tag("option", "Summit")
        with_tag("option", "Davis")
      end

    end
  end
end


