require 'hpricot'

steps_for(:prepopulate_cmr_uat) do
  
  When("I search for the non-existent person '$person' with a birth date of '$birth_date'") do |person, birth_date|
    get "/search/people?name=#{person}&birth_date=#{birth_date}"
  end
  
  Then("there should be a link to create a new CMR") do
    # response.should have_tag("a", "Start a CMR with the criteria that you searched on.") # Not working, the same thing works in the spec?
    response.should have_text(/Start a CMR with the criteria that you searched on./)
    
    # Is there some way to do the following with what Rails + Rspec provides, without needing the following parsing?
    doc = Hpricot(response.body)
    @link = (doc/"#start_cmr").first.attributes["href"]
  end
  
  When("I click the link to create a new CMR") do
    get @link
  end
  
  Then("the new CMR view displays") do
    response.should render_template(:new)
    response.should have_text(/New Confidential Morbidity Report/)
  end
  
  Then("'$first_name' should display in the first name field") do |first_name|
    # How best to see that the value is in the right field?
   response.should have_text(/#{first_name}/)
  end
  
  Then("'$last_name' should display in the last name field") do |last_name|
    # How best to see that the value is in the right field?
    response.should have_text(/#{last_name}/)
  end
  
  Then("'$birth_date' should display in the birth date field") do |birth_date|
    # How best to see that the value is in the right field?
    response.should have_text(/#{birth_date}/)
  end
    
end
