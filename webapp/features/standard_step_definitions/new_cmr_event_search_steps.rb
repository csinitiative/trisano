# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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


Given /^I am logged in as a user without view or update privileges in Davis County$/ do
  log_in_as("investigator")
end

Given /^there are ([0-9]+) morbidity events for a single person with the last name (.+)$/ do | count, last_name |
  e = create_basic_event('morbidity', last_name)
  count.to_i.times { e.clone_event.save }
end

Given /^the following morbidity events:$/ do |morbs|
  morbs.hashes.each do |morb|
    hash = {
      "first_reported_PH_date" => Date.yesterday.to_s(:db),
      "interested_party_attributes" => {
        "person_entity_attributes" => {
          "person_attributes" => morb
        }
      },
      "jurisdiction_attributes" => { "secondary_entity_id" => Place.all_by_name_and_types("Unassigned", 'J', true).first.entity_id }
    }
    MorbidityEvent.create!(hash)
  end
end

Given /^there is an associated encounter event$/ do
  @encounter = add_encounter_to_event(@event)
end

Given /^a person with the last name "(.+)"$/ do |last_name|
  PersonEntity.create(:person_attributes => { :last_name => last_name } )
end

Given /^a deleted person with the last name "(.+)"$/ do |last_name|
  PersonEntity.create(:deleted_at => Date.today, :person_attributes => { :last_name => last_name } )
end

When /^I create a new morbidity event from the morbidity named (.+)$/ do | last_name |
  click_link_within "#entity_#{@event.interested_party.person_entity.id}", "Create and edit CMR using this person"
end

When /^I create a new morbidity event from the contact named (.+)$/ do | last_name |
  click_link_within "#entity_#{@contact_event.interested_party.person_entity.id}", "Create and edit CMR using this person"
end

When /^I search for last_name = "([^\"]*)"$/ do |last_name|
  visit event_search_cmrs_path
  fill_in "last_name", :with => last_name
  click_button "Search"
end

When /^I search for:$/i do |search_fields|
  visit event_search_cmrs_path
  in_fields(search_fields) do |field, value|
    fill_in field, :with => value
  end
  click_button "Search"
end

Then /^I should see the following values:$/i do |field_values|
  in_fields(field_values) do |field, value|
    field_labeled(field).value.should == value
  end
end

When /^I search for last_name = "([^\"]*)" for people entities$/ do |last_name|
  visit event_search_cmrs_path
  fill_in "last_name", :with => last_name
  check "search_people_entities"
  click_button "Search"
end

When /^I search for last_name "([^\"]*)" and first_name = "([^\"]*)"$/ do |last_name, first_name|
  visit event_search_cmrs_path
  fill_in "last_name", :with => last_name
  fill_in "first_name", :with => first_name
  click_button "Search"
end

When /^I search for last name = "([^\"]*)" and birth date = "([^\"]*)"$/ do |last_name, birth_date|
  visit event_search_cmrs_path
  fill_in "last_name", :with => last_name
  fill_in "birth_date", :with => birth_date
  click_button "Search"
end

When /^I search for birth date = "([^\"]*)"$/ do |birth_date|
  visit event_search_cmrs_path
  fill_in "birth_date", :with => birth_date
  click_button "Search"
end

When /^I search for last_name starting with "([^\"]*)"$/ do |last_name|
  visit event_search_cmrs_path
  fill_in "last_name", :with => last_name
  check "use_starts_with_search"
  click_button "Search"
end

When /^I search for first_name starting with "([^\"]*)"$/ do |first_name|
  visit event_search_cmrs_path
  fill_in "first_name", :with => first_name
  check "use_starts_with_search"
  click_button "Search"
end

When /^I search for last_name starting with "([^\"]*)" and first_name starting with "([^\"]*)"$/ do |last_name, first_name|
  visit event_search_cmrs_path
  fill_in "last_name", :with => last_name
  fill_in "first_name", :with => first_name
  check "use_starts_with_search"
  click_button "Search"
end

Then /^I should see a search form$/ do
  response.should have_selector("form[method='get'][action='#{event_search_cmrs_path}']")
  field_labeled("Last name").value.should be_nil
end

Then /^I should not see a link to enter a new CMR$/ do
  response.should_not have_selector("a[href='#{new_cmr_path}']")
end

Then /^I should see results for Jones and Joans$/ do
  response.should have_selector("table.list") do |table|
    table.should contain("Jones")
    table.should contain("Joans")
  end
end

Then /^I should see no results$/ do
  response.should contain("No results")
end

Then /^the search field should contain Jones$/ do
  field_labeled("Last name").value.should == "Jones"
end

Then /^I should see results for both records$/ do
  response.should have_selector("table.list") do |table|
    table.should have_selector("tr") do |tr|
      tr.should contain("Jones")
      tr.should contain("Morbidity Event")
    end
    table.should have_selector("tr") do |tr|
      tr.should contain("Jones")
      tr.should contain("Contact Event")
    end
  end
end

Then /^I should see both the CMR and the entity/ do
  response.should have_selector("table.list") do |table|
    table.should have_selector("tr") do |tr|
      tr.should contain("Jones")
      tr.should contain("Morbidity Event")
    end
    table.should have_selector("tr") do |tr|
      tr.should contain("Jones")
      tr.should contain("None")
    end
  end
end

Then /^I should see the CMR but not the entity/ do
  response.should have_selector("table.list") do |table|
    table.count.should == 1
    table.should have_selector("tr") do |tr|
      tr.should contain("Jones")
      tr.should contain("Morbidity Event")
    end

    table.should_not have_xpath "//table[@class='list']//tr[not(contains(text(), 'Morbidity Event'))]"
  end
end


Then /^I should see results for just the morbidity event$/ do
  response.should have_selector("table.list") do |table|
    table.should have_selector("tr") do |tr|
      tr.should contain("Morbidity Event")
    end
  end
  response.should_not contain("Encounter Event")
end

Then /^the contact event search result should be styled search-inactive/i do
  response.should have_selector("tr.search-inactive") do |tr|
    tr.should contain(@contact_event.party.full_name)
  end
end

Then /^the disease should show as 'private'$/ do
  response.should contain("Private")
  response.should_not contain("Mumps")
end

Then /^I should the correct actions for an out\-of\-jurisdiction event$/ do
  response.should have_xpath("//tr[@class='search-active tabular']//td//a[contains(text(), 'Show')]")
  response.should_not have_xpath("//tr[@class='search-active tabular']//td//a[contains(text(), 'Edit')]")
end

Then /^I should see two morbidity events under one name$/ do
  response.should have_selector("table.list tr:nth-child(2)") do |tr|
    tr.should contain("Jones")
    tr.should contain("Morbidity Event")
  end
  response.should have_selector("tr:nth-child(3)") do |tr|
    tr.should_not contain("Jones")
    tr.should contain("Morbidity Event")
  end
end

Then /^I should be in edit mode for a new copy of (.+)$/ do |last_name|
  current_url.should =~ /(\d?)\/edit/
  $1.should_not == @event.id
  $1.should_not == @contact_event.id if @contact_event
  field_with_id("morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_last_name").value.should == last_name
end

Then /^I should see the following results:$/ do |results|
  results.rows.each_with_index do |result, i|
    response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(1)") { |td|
      td.inner_text.should =~ /#{result[0]}, #{result[1]}/
    }
  end
end

And /^I click "Start a CMR with the criteria you searched on"$/ do
  submit_form "new_cmr_form"
end

def in_fields(table)
  table.hashes.each do |hash|
    hash.each do |field, value|
      yield(field, value)
    end
  end
end
