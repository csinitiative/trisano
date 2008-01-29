module LocationFormSpecHelper
  describe "a location form", :shared => true do
    fixtures :codes

    before(:each) do
      @person_id = 1
      @person = mock_model(Person, :first_name => 'Phil', :last_name => "Silvers")
      @location = mock_model(Location, :id => 1)
      @person_entity = mock_model(PersonEntity, :id => 1)

      @entities_location = mock_entities_location
      @address = mock_address


      assigns[:person_id] = @person_id
      assigns[:person] = @person
      assigns[:person_entity] = @person_entity
      assigns[:location] = @location
      assigns[:entities_location] = @entities_person
      assigns[:address] = @address
    end
  
    it "should render the form elements" do
      do_render

      response.should have_tag("form") do
        with_tag('input#address_street_name[name=?]', "address[street_name]")
        with_tag("input#address_street_number[name=?]", "address[street_number]")
        with_tag('input#address_unit_number[name=?]', "address[unit_number]")
        with_tag('select#address_city_id[name=?]', "address[city_id]")
        with_tag('select#address_state_id[name=?]', "address[state_id]")
        with_tag('select#address_county_id[name=?]', "address[county_id]")
        with_tag('select#address_district_id[name=?]', "address[district_id]")
        with_tag('input#address_postal_code[name=?]', "address[postal_code]")
      end
    end
  end

  def mock_entities_location
    el = mock_model(EntitiesLocation)
    el.stub!(:entity_location_type_id).and_return(1302)
    el.stub!(:primary_yn_id).and_return(1401)
    el
  end

  def mock_address
    a = mock_model(Address)
    a.stub!(:street_number).and_return("123")
    a.stub!(:street_name).and_return("Elm St.")
    a.stub!(:unit_number).and_return("99")
    a.stub!(:city_id).and_return(401)
    a.stub!(:state_id).and_return(1001)
    a.stub!(:postal_code).and_return("12345")
    a.stub!(:county_id).and_return(1101)
    a.stub!(:district_id).and_return(1201)
    a
  end
end
