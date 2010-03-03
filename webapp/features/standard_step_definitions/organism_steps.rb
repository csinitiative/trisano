Then /^I should see the following organisms:$/ do |expected_table|
  selectors = lambda do |e|
    [
     e.css('th:nth-child(1)', 'td:nth-child(1)').text.strip,
     e.css('th:nth-child(2)', 'td:nth-child(2)').text.gsub("\302\240", ' ').gsub(/\W+/, ' ').strip
    ]
  end
  t = tableish('#organisms tr', selectors)
  expected_table.diff! t
end

Given /^disease "([^\"]*)" is linked to organism "([^\"]*)"$/ do |disease_name, organism_name|
  disease = Disease.find_or_create_by_disease_name :disease_name => disease_name, :active => true
  organism = Organism.find_by_organism_name organism_name
  organism.diseases << disease
  organism.save!
end
