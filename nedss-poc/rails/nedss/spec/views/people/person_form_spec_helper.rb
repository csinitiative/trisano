module PersonFormSpecHelper
  describe "a person form", :shared => true do
    fixtures :codes

    before(:each) do
      @person = mock_person
      assigns[:person] = @person
    end
  
    it "should render the form elements" do
      do_render

      response.should have_tag("form") do
        with_tag("input#person_last_name[name=?]", "person[last_name]")
        with_tag('input#person_first_name[name=?]', "person[first_name]")
        with_tag('input#person_middle_name[name=?]', "person[middle_name]")
        with_tag('select#person_birth_gender_id[name=?]', "person[birth_gender_id]") do
          with_tag('option', 'Male')
          with_tag('option', 'Female')
          with_tag('option', 'Unknown')
        end
        with_tag('select#person_current_gender_id[name=?]', "person[current_gender_id]") do
          with_tag('option', 'Male')
          with_tag('option', 'Female')
          with_tag('option', 'Unknown')
        end
        with_tag('select#person_ethnicity_id[name=?]', "person[ethnicity_id]") do
          with_tag('option', 'Hispanic')
          with_tag('option', 'Non-Hispanic')
          with_tag('option', 'Other')
          with_tag('option', 'Unknown')
        end
        with_tag('select#person_race_id[name=?]', "person[race_id]") do
          with_tag('option', 'White')
          with_tag('option', 'Black / African-American')
          with_tag('option', 'Asian')
          with_tag('option', 'American Indian')
          with_tag('option', 'Alaskan Native')
          with_tag('option', 'Native Hawaiian / Pacific Islander')
          with_tag('option', 'Unknown')
        end
        with_tag('select#person_primary_language_id[name=?]', "person[primary_language_id]") do
          with_tag('option', 'English')
          with_tag('option', 'Spanish')
        end
        with_tag('input#person_birth_date[name=?]', "person[birth_date]")
        with_tag('input#person_date_of_death[name=?]', "person[date_of_death]")
      end
    end
  end

  def mock_person
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
    person.stub!(:race_id).and_return(201)
    person.stub!(:primary_language_id).and_return(301)
    person
  end
end
