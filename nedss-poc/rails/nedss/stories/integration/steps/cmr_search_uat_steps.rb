steps_for(:cmr_search_uat) do
  
    When("I search for all CMRs for the known person '$person' with the disease '$disease'") do |person, disease|
      diseases = Disease.find(:all)
      diseases.each do |d|
        if d.disease_name == disease
          @search_id = d.id
        end
      end
      
      get "/search/cmrs?disease=#{@search_id}&name=#{person}"
    end
  
    Then("I should see at least one result with the person '$person' and the disease '$disease'") do |person, disease|  
      response.should_not have_text(/no results/)
      
      # This needs to be refined, as the person and disease will show up just because they are in the search fields of the response
      response.should have_text(/#{person}/)
      response.should have_text(/#{disease}/)
    end
    
    Then("the results should also include record number, age, county, and event date") do
      # See about pulling these values out of the fixtures
      response.should have_text(/2008500001/)
      response.should have_text(/Salt Lake/)
      response.should have_text(/31/)
      response.should have_text(/2008-03-11/)
    end
    
    When("I search for all CMRs with the starts-with first name of '$first_name' and the last name starts-with of '$last_name'") do |first_name, last_name|
      get "/search/cmrs?sw_last_name=#{last_name}&sw_first_name=#{first_name}"
    end
    
    Then("I should see at least one result with the person '$person'") do |person|
       response.should_not have_text(/no results/)
       response.should have_text(/#{person}/)
    end

    When("I search for all CMRs with the starts-with first name of '$first_name'") do |first_name|
      get "/search/cmrs?sw_first_name=#{first_name}"
    end
    
    Then("I should see at least one result with the person '$person'") do |person|
       response.should_not have_text(/no results/)
       response.should have_text(/#{person}/)
    end

    When("I search for all CMRs with the starts-with last name of '$last_name'") do |last_name|
      get "/search/cmrs?sw_last_name=#{last_name}"
    end
    
    Then("I should see at least one result with the person '$person'") do |person|
       response.should_not have_text(/no results/)
       response.should have_text(/#{person}/)
    end
    
  When("I search for all CMRs with the full text name of '$fulltext_name' and the starts-with last name of '$starts_with_last_name'") do |fulltext_name, starts_with_last_name|
      get "/search/cmrs?name=#{fulltext_name}&sw_last_name=#{starts_with_last_name}"
    end
    
    Then("the full text search should be ignored and no results should display") do
      response.should have_text(/no results/)
    end
    
end
