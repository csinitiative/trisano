require File.dirname(__FILE__) + '/../../spec_helper'

describe "/locations/show.html.erb" do
  include LocationsHelper
  
  before(:each) do
    @city = @state = @district = @county = mock_model(Code)
    @type = @primary = mock_model(Code)

    @city.stub!(:code_description).and_return('Brooklyn')
    @state.stub!(:code_description).and_return('New York')
    @district.stub!(:code_description).and_return('None')
    @county.stub!(:code_description).and_return('Kings')

    @person = mock_model(Person)
    @person.stub!(:entity_id).and_return(1)
    @person.stub!(:last_name).and_return("Marx")
    @person.stub!(:first_name).and_return("Groucho")

    @address = mock_model(Address)
    @address.stub!(:street_number).and_return("123")
    @address.stub!(:street_name).and_return("Elm St.")
    @address.stub!(:unit_number).and_return("99")
    @address.stub!(:city).and_return(@city)
    @address.stub!(:state).and_return(@state)
    @address.stub!(:postal_code).and_return("12345")
    @address.stub!(:county).and_return(@county)
    @address.stub!(:district).and_return(@district)

    @location = mock_model(Location)
    @location.stub!(:id).and_return(1)
    @location.stub!(:type).and_return("Work")
    @location.stub!(:primary?).and_return("Yes")
    @location.stub!(:current_address).and_return(@address)

    assigns[:person] = @person
    assigns[:location] = @location
  end

  it "should render attributes in <p>" do
    render "/locations/show.html.erb"

    response.should have_text(/#{@person.last_name}/)
    response.should have_text(/#{@person.first_name}/)
    response.should have_text(/#{@location.type}/)
    response.should have_text(/#{@address.street_name}/)
    response.should have_text(/#{@address.street_number}/)
  end
end

