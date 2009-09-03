Given /^an organism named "([^\"]*)"$/ do |name|
  Organism.create! :organism_name => name
end

Given /^the following organisms:$/ do |table|
  table.map_headers! 'Organism Name' => :organism_name
  table.hashes.each do |attributes|
    Organism.create! attributes
  end
end

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
