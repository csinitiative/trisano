require File.dirname(__FILE__) + '/../../spec_helper'

describe "/people/show.html.erb" do
  include EntitiesHelper
  ActionController::Base.set_view_path(RAILS_ROOT + '/app/views/entities')
  
  before(:each) do

    @gender = @ethnicity = @race = @language = @yesno = mock_model(ExternalCode)
    @state = @county = @district = mock_model(ExternalCode)

    @gender.stub!(:code_description).and_return('Male')
    @ethnicity.stub!(:code_description).and_return('Hispanic')
    @race.stub!(:code_description).and_return('Asian')
    @language.stub!(:code_description).and_return('Spanish')
    @yesno.stub!(:code_description).and_return('No')
    
    @state.stub!(:code_description).and_return('UT')
    @county.stub!(:code_description).and_return('Alpine')
    @district.stub!(:code_description).and_return('Beaver')

    @person = mock_model(Person)
    @person.stub!(:entity_id).and_return("1")
    @person.stub!(:last_name).and_return("Marx")
    @person.stub!(:first_name).and_return("Groucho")
    @person.stub!(:middle_name).and_return("Julius")
    @person.stub!(:birth_date).and_return(Date.parse('1902-10-02'))
    @person.stub!(:date_of_death).and_return(Date.parse('1970-4-21'))
    @person.stub!(:birth_gender).and_return(@gender)
    @person.stub!(:ethnicity).and_return(@ethnicity)
    @person.stub!(:primary_language).and_return(@language)
    @person.stub!(:approximate_age_no_birthday).and_return(50)
    @person.stub!(:telephone_entities_locations).and_return([])

    @address = mock_model(Address)
    @address.stub!(:street_number).and_return("123")
    @address.stub!(:street_name).and_return("Elm St.")
    @address.stub!(:unit_number).and_return("99")
    @address.stub!(:city).and_return("Provo")
    @address.stub!(:state).and_return(@state)
    @address.stub!(:postal_code).and_return("12345")
    @address.stub!(:county).and_return(@county)
    @address.stub!(:district).and_return(@district)

    @phone = mock_model(Telephone)
    @phone.stub!(:area_code).and_return("212")
    @phone.stub!(:phone_number).and_return("555-1212")
    @phone.stub!(:extension).and_return("9999")
    @phone.should_receive(:simple_format).and_return("(212) 555-1212 Ext. 9999")
    @phone.stub!(:email_address).and_return("billg@microsoft.com")
    
    @address_location = mock_model(Location)
    @address_location.stub!(:entities_locations).and_return([@entites_location])
    @address_location.stub!(:current_address).and_return(@address)
    @address_location.stub!(:primary?).and_return(true)
    @address_location.stub!(:type).and_return('Work')
    @address_location.stub!(:current_phone).and_return(nil)
    
    @telephone_location = mock_model(Location)
    @telephone_location.stub!(:entities_locations).and_return([@telephone_entities_location])
    @telephone_location.stub!(:current_phone).and_return(@phone)
    @telephone_location.stub!(:primary?).and_return(false)
    @telephone_location.stub!(:type).and_return('Unknown')

    @entities_location = mock_model(EntitiesLocation)
    @entities_location.stub!(:entity_id).and_return("1")
    @entities_location.stub!(:entity_location_type_id).and_return("1302")
    @entities_location.stub!(:primary_yn_id).and_return("1402")
    @entities_location.stub!(:location).and_return(@address_location)

    @work_phone_entity_location_type = mock(ExternalCode)
    @work_phone_entity_location_type.should_receive(:code_description).and_return('Work')
    
    @telephone_entities_location = mock_model(EntitiesLocation)
    @telephone_entities_location.stub!(:entity_id).and_return("1")
    @telephone_entities_location.stub!(:entity_location_type_id).and_return("2311")
    @telephone_entities_location.stub!(:entity_location_type).and_return(@work_phone_entity_location_type)
    @telephone_entities_location.stub!(:primary_yn_id).and_return("1401")
    @telephone_entities_location.stub!(:current_phone).and_return(@phone)
    @telephone_entities_location.stub!(:location).and_return(@telephone_location)

    @entity = mock_model(Entity)
    @entity.stub!(:entity_type).and_return('person')
    @entity.stub!(:person).and_return(@person)
    @entity.stub!(:entities_location).and_return(@entities_location)
    @entity.stub!(:telephone_entities_location).and_return(@telephone_entities_location)
    
    
    @entity.stub!(:address).and_return(@address)
    @entity.stub!(:telephone).and_return(@phone)
    @entity.stub!(:current_locations).and_return([@address_location])
    @entity.stub!(:locations).and_return([@address_location, @telephone_location])
    @entity.stub!(:races).and_return([@race])
    @entity.stub!(:primary_entities_location).and_return(@entities_location)
    @entity.stub!(:primary_phone_entities_location).and_return(@telephone_entities_location)
    @entity.stub!(:telephone_entities_locations).and_return([@telephone_entities_location])
    
    @event_form = mock(ExtendedFormBuilder)
    
    assigns[:event_form] = @event_form
    assigns[:entity] = @entity
    assigns[:locations] = Array.new
    assigns[:type] = 'person'
    assigns[:valid_types] = ['person', 'animal', 'place', 'material']
  end

  it "should render attributes" do
    pending "Local needed by included partial not found. How to assign this?"
    render "/entities/show.html.erb"

    response.should have_text(/#{@person.last_name}/)
    response.should have_text(/#{@person.first_name}/)
    response.should have_text(/#{@person.middle_name}/)
    response.should have_text(/#{@person.birth_date}/)
    response.should have_text(/#{@person.ethnicity.code_description}/)
    response.should have_text(/#{@person.birth_gender.code_description}/)
    response.should have_text(/#{@entity.races.first.code_description}/)
    response.should have_text(/#{@person.primary_language.code_description}/)

    response.should have_text(/Work/)
    response.should have_text(/#{@address.street_number}/)
    response.should have_text(/#{@address.street_name}/)
    response.should have_text(/#{@address.unit_number}/)
    response.should have_text(/#{@address.city}/)
    response.should have_text(/#{@address.state.code_description}/)
    response.should have_text(/#{@address.county.code_description}/)
    response.should have_text(/#{@address.district.code_description}/)

    response.should have_text(/#{@phone.area_code}/)
    response.should have_text(/#{@phone.phone_number}/)
  end
end

