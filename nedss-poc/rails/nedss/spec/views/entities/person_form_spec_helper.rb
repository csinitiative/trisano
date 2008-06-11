module PersonFormSpecHelper
  describe "a person form", :shared => true do
    fixtures :codes

    before(:each) do
      @entity = mock_person_entity
      @event = mock_event
      @event.stub!(:under_investigation?).and_return(false)
      @event.stub!(:reopened?).and_return(false)
      
      
      assigns[:entity] = @entity
      assigns[:type] = 'person'
      assigns[:event] = @event
    end
  
    it "should render the form elements" do
      do_render

      response.should have_tag("form") do
        with_tag("input#entity_person_last_name[name=?]", "entity[person][last_name]")
        with_tag('input#entity_person_first_name[name=?]', "entity[person][first_name]")
#        with_tag('input#entity_person_middle_name[name=?]', "entity[person][middle_name]")
        with_tag('select#entity_person_birth_gender_id[name=?]', "entity[person][birth_gender_id]") do
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
#        with_tag('input#entity_person_date_of_death[name=?]', "entity[person][date_of_death]")
      end
    end
  end
end
