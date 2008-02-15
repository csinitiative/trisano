require File.dirname(__FILE__) + '/../../spec_helper'

describe "/people/show.html.erb" do
  include EntitiesHelper
  ActionController::Base.set_view_path(RAILS_ROOT + '/app/views/entities')
  
  before(:each) do

    @gender = @ethnicity = @race = @language = mock_model(Code)
    @city = @state = @county = @district = mock_model(Code)

    @gender.stub!(:code_description).and_return('Male')
    @ethnicity.stub!(:code_description).and_return('Hispanic')
    @race.stub!(:code_description).and_return('Asian')
    @language.stub!(:code_description).and_return('Spanish')

    @city.stub!(:code_description).and_return('Salt Lake')
    @state.stub!(:code_description).and_return('UT')
    @county.stub!(:code_description).and_return('Alpine')
    @district.stub!(:code_description).and_return('Beaver')

    @person = mock_model(Person)
    @person.stub!(:entity_id).and_return("1")
    @person.stub!(:last_name).and_return("Marx")
    @person.stub!(:first_name).and_return("Groucho")
    @person.stub!(:middle_name).and_return("Julius")
    @person.stub!(:birth_date).and_return('1890-10-2')
    @person.stub!(:date_of_death).and_return('1970-4-21')
    @person.stub!(:birth_gender).and_return(@gender)
    @person.stub!(:current_gender).and_return(@gender)
    @person.stub!(:ethnicity).and_return(@ethnicity)
    @person.stub!(:primary_language).and_return(@language)

    @entities_location = mock_model(EntitiesLocation)
    @entities_location.stub!(:entity_id).and_return("1")
    @entities_location.stub!(:entity_location_type_id).and_return("1302")
    @entities_location.stub!(:primary_yn_id).and_return("1402")

    @address = mock_model(Address)
    @address.stub!(:street_number).and_return("123")
    @address.stub!(:street_name).and_return("Elm St.")
    @address.stub!(:unit_number).and_return("99")
    @address.stub!(:city).and_return(@city)
    @address.stub!(:state).and_return(@state)
    @address.stub!(:postal_code).and_return("12345")
    @address.stub!(:county).and_return(@county)
    @address.stub!(:district).and_return(@district)

    @phone = mock_model(Telephone)
    @phone.stub!(:area_code).and_return("212")
    @phone.stub!(:phone_number).and_return("555-1212")
    @phone.stub!(:extension).and_return("9999")

    @location = mock_model(Location)
    @location.stub!(:entities_locations).and_return([@entites_location])
#    @location.stub!(:addresses).and_return([@address])
    @location.stub!(:current_address).and_return(@address)
    @location.stub!(:current_phone).and_return(@phone)
    @location.stub!(:primary?).and_return(true)
    @location.stub!(:type).and_return('Work')

    @entity = mock_model(Entity)
    @entity.stub!(:entity_type).and_return('person')
    @entity.stub!(:person).and_return(@person)
    @entity.stub!(:entities_location).and_return(@entities_location)
    @entity.stub!(:address).and_return(@address)
    @entity.stub!(:telephone).and_return(@phone)
    @entity.stub!(:current_locations).and_return([@location])
    @entity.stub!(:locations).and_return([@location])
    @entity.stub!(:races).and_return([@race])

    assigns[:entity] = @entity
    assigns[:locations] = Array.new
    assigns[:type] = 'person'
    assigns[:valid_types] = ['person', 'animal', 'place', 'material']
  end

  it "should render attributes" do
    render "/entities/show.html.erb"

    response.should have_text(/#{@person.last_name}/)
    response.should have_text(/#{@person.first_name}/)
    response.should have_text(/#{@person.middle_name}/)
    response.should have_text(/#{@person.birth_date}/)
    response.should have_text(/#{@person.date_of_death}/)
    response.should have_text(/#{@person.ethnicity.code_description}/)
    response.should have_text(/#{@person.birth_gender.code_description}/)
    response.should have_text(/#{@entity.races.first.code_description}/)
    response.should have_text(/#{@person.primary_language.code_description}/)

    response.should have_text(/Work/)
    response.should have_text(/#{@address.street_number}/)
    response.should have_text(/#{@address.street_name}/)
    response.should have_text(/#{@address.unit_number}/)
    response.should have_text(/#{@address.city.code_description}/)
    response.should have_text(/#{@address.state.code_description}/)
    response.should have_text(/#{@address.county.code_description}/)
    response.should have_text(/#{@address.district.code_description}/)

    response.should have_text(/#{@phone.area_code}/)
    response.should have_text(/#{@phone.phone_number}/)
  end
end

