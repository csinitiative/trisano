require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forms/index.html.haml" do
  include FormsHelper
  
  before(:each) do
    @disease = mock_model(Disease)
    @disease.stub!(:disease_name).and_return("Anthrax")

    @place = mock_model(Place)
    @place.stub!(:name).and_return("Davis")
    @entity = mock_model(Entity)
    @entity.stub!(:current_place).and_return(@place)

    form_98 = mock_model(Form)
    form_98.should_receive(:name).and_return("Anthrax Form")
    form_98.should_receive(:description).and_return("Form for Anthrax")
    form_98.should_receive(:diseases).and_return([@disease])
    form_98.should_receive(:jurisdiction).twice.and_return(@entity)
    form_98.stub!(:status).and_return('Not Published')

    form_99 = mock_model(Form)
    form_99.should_receive(:name).and_return("MyString")
    form_99.should_receive(:description).and_return("Form for Anthrax")
    form_99.should_receive(:diseases).and_return([@disease])
    form_99.should_receive(:jurisdiction).twice.and_return(@entity)
    form_99.stub!(:status).and_return('Not Published')

    assigns[:forms] = [form_98, form_99]
  end

  it "should render list of forms" do
    pending
    render "/forms/index.html.haml"
    response.should have_tag("tr>td", "Anthrax Form", 2)
    response.should have_tag("tr>td", "Form for Anthrax", 2)
    response.should have_tag("tr>td", "Anthrax", 2)
    response.should have_tag("tr>td", "Davis", 2)
  end
end
