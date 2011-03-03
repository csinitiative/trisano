def lookup_jurisdiction(jurisdiction_name)
  Place.first(:conditions => { :short_name => jurisdiction_name })
end

When /^I retrieve the event's XML representation$/ do
  header "Accept", 'application/xml'
  visit cmr_path(@event)
  @xml = Nokogiri::XML(response.body)
end

When /^I retrieve the contact event's XML representation$/ do
  header "Accept", 'application/xml'
  visit contact_event_path(@contact_event)
  @xml = Nokogiri::XML(response.body)
end

When /^I retrieve a new CMR xml representation$/ do
  header "Accept", "application/xml"
  visit new_cmr_path
  @xml = Nokogiri::XML(response.body)
end

When /^I retrieve the edit_jurisdiction CMR XML representation$/ do
  header "Accept", "application/xml"
  visit edit_jurisdiction_cmr_path(@event)
  @xml = Nokogiri::XML(response.body)
end

When /^I retrieve the edit_jurisdiction contact event XML representation$/ do
  header "Accept", "application/xml"
  visit edit_jurisdiction_contact_event_path(@contact_event)
  @xml = Nokogiri::XML(response.body)
end

Then /^I should have an xml document$/ do
  headers['Content-Type'].should =~ %r{^application/xml}
  @xml.errors.should == []
end

Then /^these xpaths should exist:$/ do |table|
  table.rows.each do |row|
    @xml.xpath(row.first.strip).size.should == 1
  end
end

When /^I use xpath to find (.*)$/ do |xpath_name|
  @node_set = @xml.xpath(xpath_to(xpath_name))
end

When /^I make the XML invalid$/ do
  @xml.at_xpath("//first-reported-PH-date").content = ""
end

When /^I PUT the XML back/ do
  url = @xml.at_xpath("//atom:link[@rel='self']").attribute('href').value
  put url, @xml.to_xml, 'Accept' => 'application/xml', 'Content-Type' => 'application/xml'
end

When /^I POST the XML to the "([^\"]*)" link$/ do |link_type|
  url = @xml.at_xpath("//atom:link[@rel='#{link_type}']").attribute('href').value
  post url, @xml.to_xml, 'Accept' => 'application/xml', 'Content-Type' => 'application/xml'
end

Then /^I should have (\d+) node$/ do |count|
  @node_set.size.should == count.to_i
end

When /^I replace (.*) with "([^\"]*)"$/ do |xpath_name, value|
  nodes = @xml.xpath(xpath_to(xpath_name))
  nodes.should_not be_empty
  nodes.each do |element|
    element.content = value
  end
end

When /^I replace jurisdiction-id with jurisdiction "([^\"]*)"$/ do |jurisdiction_name|
  @jurisdiction = lookup_jurisdiction jurisdiction_name
  @jurisdiction.should_not be_blank
  value = @jurisdiction.entity_id

  nodes = @xml.xpath('/routing/jurisdiction-id')
  nodes.should_not be_empty
  nodes.each do |element|
    element.content = value
  end
end

When /^I invalidate the jurisdiction$/ do
  value = PersonEntity.first.id
  nodes = @xml.xpath('/routing/jurisdiction-id')
  nodes.should_not be_empty
  nodes.each do |element|
    element.content = value
  end
end

When /^I add the assignment note "([^\"]*)"$/ do |note|
  nodes = @xml.xpath('/routing/note')
  nodes.should_not be_empty
  nodes.each do |element|
    element.content = note
  end
end

When /^I replace (.*) with (.*)'s date$/ do |xpath_name, date_word|
  date = DateTime.send(date_word).xmlschema
  nodes = @xml.xpath(xpath_to(xpath_name))
  nodes.should_not be_empty
  nodes.each do |element|
    element.content = date
  end
end

Then /^the Location header should have a link to the new event$/ do
  headers['Location'].should =~ %r{http://www.example.com/cmrs/\d+}
end

Then /^I should see the new jurisdiction$/ do
  value = @jurisdiction.entity_id
  response.should have_xpath "//jurisdiction-attributes/secondary-entity-id[contains(text(), '#{value}')]"
end

When /^I add "([^\"]*)" as (a|an) (.*) note$/ do |note_text, ignore, note_type|
  note_form = @xml.at_xpath("//notes-attributes").children.last
  note_form.css('note').first.content = note_text
  note_form.css('note-type').first.content = note_type
end
