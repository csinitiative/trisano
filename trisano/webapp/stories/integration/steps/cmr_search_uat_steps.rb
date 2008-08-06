steps_for(:cmr_search_uat) do
  
  Given("I am logged in as an investigator") do
    ENV['NEDSS_UID'] = 'utah'
  end

  Given("a CMR is created in $jurisdiction for a $gender named $first_name $last_name of $county county born $birth_date and infected with $disease") do | jurisdiction, gender, first_name, last_name, county, birth_date, disease |
    add_event(jurisdiction, gender, first_name, last_name, county, birth_date, disease)
  end

  When("I search for CMRs for people named $person infected with $disease") do |person, disease|
    disease_id = Disease.find_by_disease_name(disease).id
    get "/search/cmrs?disease=#{disease_id}&name=#{person}"
  end
  
  Then("the results should contain a record number, a link to $person, his age and the birth date $birth_date, gender $gender, county $county, disease $disease, jurisdiction $jurisdiction, and today's date") do | person, birth_date, gender, county, disease, jurisdiction|
       
    response.should_not have_text(/no results/)

    gender.capitalize!
    county.capitalize!
    disease.capitalize!
    parsed_date = Date.parse(birth_date)
    birth_date = parsed_date.to_s
    age = (( Date.today - parsed_date ).to_i / 365 ).to_s
    today = Date.today.to_s

    response.should have_tag('table') do
      with_tag('tr') do
        with_tag('td') do
          with_tag('a', /\d{10}/)
        end
        with_tag('td') do
          with_tag('a', /#{person}/)
        end
        with_tag('td', /#{age} \/ #{birth_date}/ )
        with_tag('td', /#{gender}/ )
        with_tag('td', /#{county}/ )
        with_tag('td', /#{disease}/ )
        with_tag('td', /#{jurisdiction}/ )
        with_tag('td', /#{today}/ )
      end
    end
  end
    
  When("I search for CMRs where first name starts with $first_name and last name starts with $last_name") do |first_name, last_name|
    get "/search/cmrs?sw_last_name=#{last_name}&sw_first_name=#{first_name}"
  end
    
  When("I search for CMRs where first name starts with $first_name") do |first_name|
    get "/search/cmrs?sw_first_name=#{first_name}"
  end
    
  When("I search for CMRs where last name starts with $last_name") do |last_name|
    get "/search/cmrs?sw_last_name=#{last_name}"
  end
    
  When("I search for CMRs with a full text name of $fulltext_name and a last name starting with $starts_with_last_name") do |fulltext_name, starts_with_last_name|
    get "/search/cmrs?name=#{fulltext_name}&sw_last_name=#{starts_with_last_name}"
  end
    
  Then("I should see at least one result with the person $person") do |person|

    response.should_not have_text(/no results/)
    response.should have_tag('table') do
      with_tag('tr') do
        with_tag('td') do
          # Introduced span into view 'cause RSpec kept confusing the record number and person name table data elements
          with_tag('a', /#{person}/)
        end
      end
    end
  end

  Then("the full text search should be ignored and no results should display") do
    response.should have_text(/no results/)
  end
end

def add_event(jurisdiction, gender, first_name, last_name, county, birth_date, disease) 
  
  # StoryRunner swallows errors in "givens", thus we wrap in an exception handler
  begin
    disease.capitalize!
    gender.capitalize!
    county.capitalize!
    birth_date = Date.parse(birth_date) unless birth_date.class == "Date"
    breakpoint
    @event = MorbidityEvent.new(
      :event_onset_date => Date.today, 
      :disease          => { :disease_id => Disease.find_by_disease_name(disease).id },
      :active_patient   => { 
        :active_primary_entity => { 
          :person => { 
            :first_name => first_name,
            :last_name => last_name,
            :birth_date => birth_date,
            :birth_gender_id => ExternalCode.find_by_code_name_and_code_description("gender", gender).id
          },
          :entities_location => { 
            :entity_location_type_id => ExternalCode.unspecified_location_id,
            :primary_yn_id => ExternalCode.yes_id 
          },
          :address => {
            :county_id => ExternalCode.find_by_code_name_and_code_description("county", county).id
          }
        }
      },
      :active_jurisdiction => { 
        :secondary_entity_id => Place.find_by_name(jurisdiction).entity_id
      },
      :active_reporting_agency => { 
        :secondary_entity_id => nil,
        :active_secondary_entity => { 
          :place => {},
          :entities_location => {}, 
          :address => {}, 
          :telephone => {}
        }
      },
      :active_reporter => { 
        :active_secondary_entity => { 
          :person => {}, 
          :entities_location => { 
            :entity_location_type_id => ExternalCode.unspecified_location_id,
            :primary_yn_id => ExternalCode.yes_id 
          }, 
          :address => {}, 
          :telephone => {} 
      }
      }
    )

    @event.save!
  rescue
    p $!
  end
end
