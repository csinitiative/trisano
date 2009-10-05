Then /^I should see the following organisms:$/ do |expected_table|
  t = table element_at('#organisms').to_table
  t.map_headers! t.headers[1] => 'Actions'
  t.map_column! 'Organism Name' do |names|
    Nokogiri::HTML("<html>#{names}</html>").css('a').text()
  end
  t.map_column! 'Actions' do |tools|
    Nokogiri::HTML("<html>#{tools}</html>").css('a').collect{|a| a.text()}.join(',')
  end
  expected_table.diff! t
end

Given /^disease "([^\"]*)" is linked to organism "([^\"]*)"$/ do |disease_name, organism_name|
  disease = Disease.find_by_disease_name disease_name
  organism = Organism.find_by_organism_name organism_name
  organism.diseases << disease
  organism.save!
end
