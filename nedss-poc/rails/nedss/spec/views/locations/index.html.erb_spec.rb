require File.dirname(__FILE__) + '/../../spec_helper'

describe "/locations/index.html.erb" do
  include LocationsHelper
  
  before(:each) do
    person = mock_model(Person, :entity_id => 1,
                                :first_name => 'Phil', 
                                :last_name => "Silvers")

    address_1 = mock_model(Address)
    address_1.stub!(:street_name).and_return("Birch")
    address_1.stub!(:street_number).and_return("123")
    address_1.stub!(:unit_number).and_return("99")
    address_1.stub!(:city)
    address_1.stub!(:state)
    address_1.stub!(:postal_code).and_return("12345")
    address_1.stub!(:county)
    address_1.stub!(:district)

    address_2 = mock_model(Address)
    address_2.stub!(:street_name).and_return("Elm")
    address_2.stub!(:street_number).and_return("456")
    address_2.stub!(:unit_number).and_return("88")
    address_2.stub!(:city)
    address_2.stub!(:state)
    address_2.stub!(:postal_code).and_return("23456")
    address_2.stub!(:county)
    address_2.stub!(:district)

    location_1 = mock_model(Location)
    location_1.stub!(:type).and_return("Work")
    location_1.stub!(:primary?).and_return(true)
    location_1.stub!(:current_address).and_return(address_1)

    location_2 = mock_model(Location)
    location_2.stub!(:type).and_return("Home")
    location_2.stub!(:primary?).and_return(false)
    location_2.stub!(:current_address).and_return(address_2)

    assigns[:person] = person
    assigns[:locations] = [location_1, location_2]
  end

  it "should render list of locations" do
    render "/locations/index.html.erb"
  end

  it "should display street number and name in a single element" do
    render "/locations/index.html.erb"
    response.should have_tag('td', 'Work : 123 Birch, Unit: 99, 12345')
  end

  it "should show addrsss for Phil Silvers" do
    render "/locations/index.html.erb"
    response.should have_tag('h1', 'Listing locations for Phil Silvers')
  end

  it "should have rendered two addresses" do
    render "/locations/index.html.erb"
    response.should have_tag('table') do
      with_tag('tr') do
        with_tag('td', 'Work : 123 Birch, Unit: 99, 12345')
        with_tag('td', 'Home : 456 Elm, Unit: 88, 23456')
      end
    end
  end
end

