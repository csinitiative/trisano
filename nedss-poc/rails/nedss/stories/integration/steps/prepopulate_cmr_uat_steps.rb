require 'hpricot'

steps_for(:prepopulate_cmr_uat) do
  
  Given("I am logged in as an investigator") do
    ENV['NEDSS_UID'] = 'utah'
  end

  Given("no person named $first_name $last_name exists") do |first_name, last_name|
    # Do nothing, ultimately should delete when delete is ready
  end

  Given("no CMR for a person named $first_name $last_name exists") do |first_name, last_name|
    # Do nothing, ultimately should delete when delete is ready
  end

  When("I search for the person named $person, born $birthdate") do |person, birthdate|
    get "/search/people?name=#{person}&birth_date=#{birthdate}"
  end

  When("I search for a CMR associated with the person $person") do |person|
    get "/search/cmrs?name=#{person}"
  end

  When("I click the link to create a new CMR") do
    get @link
  end
  
  Then("there should be a link to create a new CMR") do
    response.should have_tag('a', 'Start a CMR with the criteria that you searched on.')
    
    # Is there some way to do the following with what Rails + Rspec provides, without needing the following parsing?
    doc = Hpricot(response.body)
    @link = (doc/"#start_cmr").first.attributes["href"]
  end
  
  Then("the new CMR view displays") do
    response.should render_template(:new)
    response.should have_text(/CONFIDENTIAL MORBIDITY REPORT/)
  end
  
  Then("$first_name should display in the first name field") do |first_name|
    response.should have_tag("input#event_active_patient__active_primary_entity__person_first_name[value=?]", first_name)
  end
  
  Then("$last_name should display in the last name field") do |last_name|
    response.should have_tag("input#event_active_patient__active_primary_entity__person_last_name[value=?]", last_name)
  end
  
  Then("$birth_date should display in the birth date field") do |birth_date|
    response.should have_tag("input#event_active_patient__active_primary_entity__person_birth_date[value=?]", birth_date)
  end
  
end
