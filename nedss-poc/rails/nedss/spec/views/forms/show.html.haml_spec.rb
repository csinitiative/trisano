require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forms/show.html.haml" do
  include FormsHelper
  
  before(:each) do
    @disease = mock_model(Disease)
    @disease.stub!(:disease_name).and_return("Anthrax")

    @place = mock_model(Place)
    @place.stub!(:name).and_return("Davis")
    @entity = mock_model(Entity)
    @entity.stub!(:current_place).and_return(@place)

    @form = mock_model(Form)
    @form.stub!(:name).and_return("Anthrax Form")
    @form.stub!(:description).and_return("Questions to ask when disease is Anthrax")
    @form.stub!(:disease).and_return(@disease)
    @form.stub!(:jurisdiction).and_return(@entity)
    @form.stub!(:status).and_return('Not Published')
    
    assigns[:form] = @form
  end

  it "should render attributes in <p>" do
    render "/forms/show.html.haml"
    response.should have_text(/Anthrax Form/)
    response.should have_text(/Questions to ask when disease is Anthrax/)
    response.should have_text(/Anthrax/)
    response.should have_text(/Davis/)
  end
end
