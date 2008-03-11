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
  
end
