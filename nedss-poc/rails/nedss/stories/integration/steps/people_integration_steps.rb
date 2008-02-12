require 'mechanize'

steps_for(:people_integration) do
  
  When("I view the people listing") do
    agent = WWW::Mechanize.new
    @page = agent.get NEDSS_URL + "/nedss/people"
  end
  
  Then("the page title should be '$page_title'") do |page_title|
    @page.title.should eql(page_title)
  end

  Then("there should be a list of people") do
    @page.links.text("Show").should have_at_least(2).items
  end
  
  Then("there should be a link to create a new person") do
    @page.links.text("New person").should have_at_least(1).items
  end
  
# Not implementing any further yet. For Release 1.2 -- until something different
# emerges -- the focus will be on user acceptance testing.
# 
#  When("I click the new person link") do
#    @page = @page.links.text("New person").first.click
#  end
#  
#  Then("I should be taken to the new person page") do
#    # Is there a good way to get at the URL? Seems fragile to go after a header
#    # to determine the page we're on.
#    @page.search("//h1").inner_text.should eql("New person")
#  end
#  
#  Given that I can enter a first name of 'Bob'
#  And that I can enter a last name of 'Ford'
#    
#  When I click the create button
#
#  Then a new person should be created

end