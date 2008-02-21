require 'mechanize'

steps_for(:search_uat) do
  
    # This was done at great speed. Debt: 
    #   DRY this up.
    #     Newing agent every time
    #   Figure out the scoping by scenarios
    #     So the whens/thens can be reused
    #     And story lines don't have to be unique
    
    When("I search for the known person '$person'") do |person|
      agent = WWW::Mechanize.new
      @page = agent.get NEDSS_URL + "/nedss/search?name=#{person}"
    end
  
    Then("known person '$person' should appear in the search results.") do |person|
      @page.links.text("#{person}").should have_at_least(1).items
    end
    
    When("I search for the non-existent person '$person'") do |person|
      agent = WWW::Mechanize.new
      @page = agent.get NEDSS_URL + "/nedss/search?name=#{person}"
    end
  
    Then("non-existent person '$person' should not be returned.") do |person|
      @page.links.text("#{person}").should have(0).items
    end
    
    When("I search with the mispelled name '$name'") do |name|
      agent = WWW::Mechanize.new
      @page = agent.get NEDSS_URL + "/nedss/search?name=#{name}"
    end
  
    Then("the correctly spelled name of '$person' should appear in the search results.") do |name|
      @page.links.text("#{name}").should have_at_least(1).items
    end
    
    When("I search with the transposed names '$name'") do |name|
      agent = WWW::Mechanize.new
      @page = agent.get NEDSS_URL + "/nedss/search?name=#{name}"
    end
  
    Then("the non-tranposed name of '$name' should appear in the search results.") do |name|
      @page.links.text("#{name}").should have_at_least(1).items
    end
    
    When("I search for the person by birthdate '$person' by the correct birthdate of '$birthdate'") do |person, birthdate|
      agent = WWW::Mechanize.new
      @page = agent.get NEDSS_URL + "/nedss/search?name=#{person}&birth_date=#{birthdate}"
    end
  
    # Scrape the birthday out, too
    Then("known person by birthdate '$person' with correct birthdate '$birthdate' should appear in the search results.") do |person, birthdate|
      @page.links.text("#{person}").should have_at_least(1).items
    end

    
#  Scenario: Search for users by incorrect birthdate
#
#    When I search for the person 'Groucho Marx' by the incorrect birthdate of 'incorrect birthdate'
#    Then 'Groucho Marx' should not appear in the search results.
#  
  
  
  
  
    
end