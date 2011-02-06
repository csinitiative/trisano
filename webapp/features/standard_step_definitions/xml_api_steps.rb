When /^I retrieve the event's XML representation$/ do
  header "Accept", 'application/xml'
  visit cmr_path(@event)
end

Then /^I should have an xml document$/ do
  headers['Content-Type'].should =~ %r{^application/xml}
  puts response.body
  @xml = Nokogiri::XML(response.body)
end

Then /^these xpaths should exist:$/ do |string|
  string.each_line do |line|
    @xml.xpath(line.strip).size.should == 1
  end
end

When /^I use xpath to find (.*)$/ do |xpath_name|
  @node_set = xpath_to(xpath_name)
end

Then /^I should have (\d+) node$/ do |count|
  @node_set.size.should == count.to_i
end
