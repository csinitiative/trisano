module PersonFormSpecHelper
  describe "a person form", :shared => true do
    fixtures :codes

    before(:each) do
      @entity = mock_person_entity
      assigns[:entity] = @entity
      assigns[:type] = 'person'
    end
  
    it "should render the form elements" do
      do_render

      response.should have_tag("form") do
        with_tag("input#entity_person_last_name[name=?]", "entity[person][last_name]")
        with_tag('input#entity_person_first_name[name=?]', "entity[person][first_name]")
        with_tag('input#entity_person_middle_name[name=?]', "entity[person][middle_name]")
        with_tag('select#entity_person_birth_gender_id[name=?]', "entity[person][birth_gender_id]") do
          with_tag('option', 'Male')
          with_tag('option', 'Female')
          with_tag('option', 'Unknown')
        end
        with_tag('select#entity_person_current_gender_id[name=?]', "entity[person][current_gender_id]") do
          with_tag('option', 'Male')
          with_tag('option', 'Female')
          with_tag('option', 'Unknown')
        end
        with_tag('select#entity_person_ethnicity_id[name=?]', "entity[person][ethnicity_id]") do
          with_tag('option', 'Hispanic or Latino')
          with_tag('option', 'Not Hispanic or Latino')
          with_tag('option', 'Other')
          with_tag('option', 'Unknown')
        end
        with_tag('select#entity_race_ids[name=?]', "entity[race_ids][]") do
          with_tag('option', 'White')
          with_tag('option', 'Black / African-American')
          with_tag('option', 'Asian')
          with_tag('option', 'American Indian')
          with_tag('option', 'Alaskan Native')
          with_tag('option', 'Native Hawaiian / Pacific Islander')
        end
        with_tag('select#entity_person_primary_language_id[name=?]', "entity[person][primary_language_id]") do
          with_tag('option', 'English')
          with_tag('option', 'Spanish')
        end
        with_tag('input#entity_person_birth_date[name=?]', "entity[person][birth_date]")
        with_tag('input#entity_person_date_of_death[name=?]', "entity[person][date_of_death]")
      end
    end
  end

  def mock_person_entity
    person = mock_model(Person)
    person.stub!(:entity_id).and_return("1")
    person.stub!(:last_name).and_return("Marx")
    person.stub!(:first_name).and_return("Groucho")
    person.stub!(:middle_name).and_return("Julius")
    person.stub!(:birth_date).and_return('1890-10-2')
    person.stub!(:date_of_death).and_return('1970-4-21')
    person.stub!(:birth_gender_id).and_return(1)
    person.stub!(:current_gender_id).and_return(1)
    person.stub!(:ethnicity_id).and_return(101)
    person.stub!(:primary_language_id).and_return(301)

    entities_location = mock_model(EntitiesLocation)
    entities_location.stub!(:entity_id).and_return("1")
    entities_location.stub!(:entity_location_type_id).and_return("1302")
    entities_location.stub!(:primary_yn_id).and_return("1402")

    address = mock_model(Address)
    address.stub!(:street_number).and_return("123")
    address.stub!(:street_name).and_return("Elm St.")
    address.stub!(:unit_number).and_return("99")
    address.stub!(:city_id).and_return(401)
    address.stub!(:state_id).and_return(1001)
    address.stub!(:postal_code).and_return("12345")
    address.stub!(:county_id).and_return(1101)
    address.stub!(:district_id).and_return(1201)

    phone = mock_model(Telephone)
    phone.stub!(:area_code).and_return("212")
    phone.stub!(:phone_number).and_return("5551212")
    phone.stub!(:extension).and_return("4444")

    entity = mock_model(Entity, :to_param => '1')
    entity.stub!(:entity_type).and_return('person')
    entity.stub!(:person).and_return(person)
    entity.stub!(:entities_location).and_return(entities_location)
    entity.stub!(:address).and_return(address)
    entity.stub!(:telephone).and_return(phone)
    entity.stub!(:race_ids).and_return([201])
    entity
  end
end
