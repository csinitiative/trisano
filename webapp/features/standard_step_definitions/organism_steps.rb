Given /^an organism named "([^\"]*)"$/ do |name|
  Organism.create! :organism_name => name
end
