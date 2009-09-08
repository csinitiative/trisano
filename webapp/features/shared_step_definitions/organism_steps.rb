Given /^an organism named "([^\"]*)"$/ do |name|
  Organism.create! :organism_name => name
end

Given /^the following organisms:$/ do |table|
  table.map_headers! 'Organism Name' => :organism_name
  table.hashes.each do |attributes|
    Organism.create! attributes
  end
end

After('@clean_organisms') do
  Organism.all.each(&:delete)
end

