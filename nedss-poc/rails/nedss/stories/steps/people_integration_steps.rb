require 'mechanize'

steps_for(:people_integration) do

  When("I view the people listing") do
    agent = WWW::Mechanize.new
    @page = agent.get 'http://localhost:3000/people'
    puts @page.title
    pending("Really implement this")
  end

  Then("there should be a list of people") do
    pending("Really implement this")
  end

end