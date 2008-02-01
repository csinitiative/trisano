require File.dirname(__FILE__) + "/helper"

steps_for(:people) do
  
  Given("a new person named '$name'") do |name|
    @person = Person.new(:last_name => name)
  end
  
  # This is more of a setup method to establish the number of people to start with
  Given("a number of existing persons") do
    @beginning_person_count = Person.count
  end
  
  
  When("I save the person") do
    @person.save
  end
  
  Then("the person should be valid") do
    @person.should be_valid
  end
  
  Then("there should be $count more persons? stored") do |count|
    Person.count.should == (@beginning_person_count + count.to_i)
  end
  
end

with_steps_for(:people) do
  run_local_story "people_story"
end