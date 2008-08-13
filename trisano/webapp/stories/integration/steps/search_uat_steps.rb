
steps_for(:search_uat) do

  # NOTE:  Similarly worded statements must appear in a certain order, most specific to least.
  # These are highlighted below

  Given("I am logged in as an investigator") do
    ENV['NEDSS_UID'] = 'utah'
  end

  Given("a person named $first_name $last_name, born $birth_date, gender $gender, and residing in $county County is created") do |first_name, last_name, birth_date, gender, county|
    add_person(first_name, last_name, birth_date, gender, county)
  end
  
  Given("no person named $first_name $last_name exists") do |first_name, last_name|
    # Do nothing, ultimately should delete when delete is ready
  end

  # This "Given" must precede the following one
  Given("a person named $first_name $last_name, born $birth_date is created") do |first_name, last_name, birth_date|
    add_person(first_name, last_name, birth_date)
  end

  # This "Given" must follow the previous one
  Given("a person named $first_name $last_name is created") do |first_name, last_name|
    add_person(first_name, last_name)
  end

  # This "when" must precede the following one
  When("I search for the person named $person, born $birthdate") do |person, birthdate|
      get "/search/people?name=#{person}&birth_date=#{birthdate}"
  end

  # This "when" must follow the preceding one
  When("I search for $person") do |person|
    get "/search/people?name=#{person}"
  end
  
  Then("$person should not be returned") do |person|
    response.should have_text(/no results/)
  end
    
  # This "then" must precede the following one
  Then("$value should appear in the search results as a link") do |value|
    response.should_not have_text(/no results/)

    response.should have_tag('table') do
      with_tag('tr') do
        with_tag('td', /#{value}/)
      end
    end
  end

  # This "then" must follow the preceding one
  Then("$value should appear in the search results") do |value|
    response.should_not have_text(/no results/)

    response.should have_tag('table') do
      with_tag('tr') do
        with_tag('td', /#{value}/ )
      end
    end
  end
    
end

def add_person(first_name = nil, last_name = nil, birth_date = "01/01/1970", gender = "Unknown", county = "Beaver")
  
  # StoryRunner swallows errors in "givens", thus we wrap in an exception handler
  begin
    gender.capitalize!
    county.capitalize!
    birth_date = Date.parse(birth_date) unless birth_date.class == "Date"
    county = ExternalCode.find_by_code_name_and_code_description("county", county)
    county_id = county.id
    birth_gender_id = ExternalCode.find_by_code_name_and_code_description("gender", gender).id

    @entity = Entity.new(
      { :entity_type => 'person',
        :person => { 
          :first_name => first_name,
          :last_name => last_name,
          :birth_date => birth_date,
          :birth_gender_id => birth_gender_id
        },
        :entities_location => { 
          :entity_location_type_id => ExternalCode.unspecified_location_id,
          :primary_yn_id => ExternalCode.yes_id 
        },
        :address => {
          :county_id => county_id
        }
      }
    )

    @entity.save!
  rescue
    p $!
  end
end
