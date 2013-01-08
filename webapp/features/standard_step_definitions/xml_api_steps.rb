# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
def lookup_jurisdiction(jurisdiction_name)
  Place.first(:conditions => { :short_name => jurisdiction_name })
end

def set_xpath_value(xpath, value)
  nodes = @xml.xpath(xpath)
  nodes.should_not be_empty
  nodes.each do |element|
    element.content = value
  end
end

When /^I retrieve the AE XML representation for (.*)$/ do |path|
  header "Accept", "application/xml"
  url = self.send "#{path}_path", @event
  visit url
  @xml = Nokogiri::XML(response.body)
end

When /^I retrieve the CMR XML representation for (.*)$/ do |path|
  header "Accept", "application/xml"
  url = self.send "#{path}_path", @event
  visit url
  @xml = Nokogiri::XML(response.body)
end

When /^I retrieve the contact event XML representation for (.*)$/ do |path|
  header "Accept", "application/xml"
  url = self.send "#{path}_path", @contact_event
  visit url
  @xml = Nokogiri::XML(response.body)
end

When /^I view the HTML event page$/ do
  header "Accept", "text/html"
  visit cmr_path(@event)
end

When /^I view the HTML contact event page$/ do
  header "Accept", "text/html"
  visit contact_event_path(@contact_event)
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
  set_xpath_value(xpath_to(xpath_name), value)
end

When /^I assign an assignable user to the task$/ do
  jurisdictions = User.current_user.jurisdictions_for_privilege(:assign_task_to_user)
  jurisdictions.should_not be_blank
  assignees = User.task_assignees_for_jurisdictions jurisdictions
  assignees.should_not be_blank
  user = assignees.find{|u| u != User.current_user}
  user.should_not be_nil
  set_xpath_value('/task/user-id', user.id)
end

When /^I assign an unassignable user to the task$/ do
  jurisdictions = User.current_user.jurisdictions_for_privilege(:assign_task_to_user)
  assignees = User.task_assignees_for_jurisdictions jurisdictions
  user = User.all.find{|u| not assignees.include?(u)}
  user.should_not be_nil
  set_xpath_value('/task/user-id', user.id)
end

When /^I assign any other user to the task$/ do
  user = User.all.find{|u| u != User.current_user}
  user.should_not be_nil
  set_xpath_value('/task/user-id', user.id)
end

When /^I replace jurisdiction-id with jurisdiction "([^\"]*)"$/ do |jurisdiction_name|
  @jurisdiction = lookup_jurisdiction jurisdiction_name
  @jurisdiction.should_not be_blank
  value = @jurisdiction.entity_id

  set_xpath_value('/routing/jurisdiction-id', value)
end

When /^I invalidate the jurisdiction$/ do
  value = PersonEntity.first.id
  set_xpath_value('/routing/jurisdiction-id', value)
end

When /^I replace (.*) with (.*)'s date$/ do |xpath_name, date_word|
  date = DateTime.send(date_word).xmlschema
  set_xpath_value(xpath_to(xpath_name), date)
end

Then /^the Location header should have a link to the new assessment event$/ do
  headers['Location'].should =~ %r{http://www.example.com/aes/\d+}
end

Then /^the Location header should have a link to the new morbidity event$/ do
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
