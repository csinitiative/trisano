When /^I retrieve the event's XML representation$/ do
  header "Accept", 'application/xml'
  visit cmr_path(@event)
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

When /^I put the XML back/ do
  header 'Accept', 'application/xml'
  put cmr_path(@event), @xml.to_xml, headers.merge('Accept' => 'application/xml')
end

Then /^I should have (\d+) node$/ do |count|
  @node_set.size.should == count.to_i
end

When /^I replace (.*) with "([^\"]*)"$/ do |xpath_name, value|
  @xml.xpath(xpath_to(xpath_name)).each do |element|
    element.content = value
  end
end
