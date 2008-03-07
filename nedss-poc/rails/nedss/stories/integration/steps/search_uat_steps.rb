require 'mechanize'

steps_for(:search_uat) do
  
    # This was done at great speed. Debt: 
    #   DRY this up.
    #   Figure out the scoping by scenarios
    #     So the whens/thens can be reused
    #     And story lines don't have to be unique
    
    When("I search for the known person '$person'") do |person|
      get "/search/people?name=#{person}"
    end
  
    Then("known person '$person' should appear in the search results.") do |person|
      # This needs to be refined, as the person will show up just because they are in the search fields of the response
      response.should have_text(/#{person}/)
    end
    
    When("I search for the non-existent person '$person'") do |person|
      get "/search/people?name=#{person}"
    end
    
    Then("non-existent person '$person' should not be returned.") do |person|
      response.should have_text(/no results/)
    end
    
    When("I search with the mispelled name '$name'") do |name|
      get "/search/people?name=#{name}"
    end
  
    Then("the correctly spelled name of '$person' should appear in the search results.") do |name|
      response.should have_text(/#{name}/)
    end
    
    When("I search with the transposed names '$name'") do |name|
      get "/search/people?name=#{name}"
    end
  
    Then("the non-tranposed name of '$name' should appear in the search results.") do |name|
      response.should have_text(/#{name}/)
    end
    
    When("I search for the person by birthdate '$person' by the correct birthdate of '$birthdate'") do |person, birthdate|
        get "/search/people?name=#{person}&birth_date=#{birthdate}"
    end
  
    Then("known person by birthdate '$person' with correct birthdate '$birthdate' should appear in the search results.") do |person, birthdate|
      # This needs to be refined, as the person and birthdate will show up just because they are in the search fields of the response
      response.should have_text(/#{person}/) 
      response.should have_text(/#{birthdate}/)
    end
    
    When("I search for the person by correct name '$person' but the incorrect birthdate of '$birthdate'") do |person, birthdate|
        get "/search/people?name=#{person}&birth_date=#{birthdate}"
    end
  
    Then("known person by incorrect birthdate '$person' should not appear in the search results.") do |person|
      response.should have_text(/no results/)
    end
    
end
