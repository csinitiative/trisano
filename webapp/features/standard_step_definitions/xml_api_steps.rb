When /^I retrieve the event's XML representation$/ do
  header "Accept", 'application/xml'
  visit cmr_path(@event)
  @xml = Nokogiri::XML(response.body)
end

When /^I retrieve a new CMR xml representation$/ do
  header "Accept", "application/xml"
  visit new_cmr_path
  @xml = Nokogiri::XML(response.body)
end

Then /^I should have an xml document$/ do
  headers['Content-Type'].should =~ %r{^application/xml}
  @xml.errors.should == []
end

Then /^these xpaths should exist:$/ do |string|
  string.each_line do |line|
    @xml.xpath(line.strip).size.should == 1
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

When /^I POST the XML to the collection$/ do
  url = @xml.at_xpath("//atom:link[@rel='index']").attribute('href').value
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

