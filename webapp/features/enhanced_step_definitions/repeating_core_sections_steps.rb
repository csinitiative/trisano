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

Given /^a published form with repeating core fields for a (.+) event$/ do |event_type|
  disease_name = SecureRandom.hex(16)
  @form = create_form(event_type, 'Already created', 'something_published', disease_name)
  Given "that form has core field configs configured for all repeater core fields"
  @published_form = @form.publish
  @published_form.should_not be_nil, "Unable to publish form. See feature logs."
  sleep 1
end

Given /^that form has core field configs configured for all repeater core fields$/ do
  @core_field_container = @form.core_field_elements_container

  # Create a core field config for every core field
  CoreField.all(:conditions => ['event_type = ? and fb_accessible = true and disease_specific != true and repeater = true', @form.event_type]).each do |core_field|
    create_core_field_config(@form, @core_field_container, core_field)
  end
end


Given /^a basic (.+) event with the form's disease$/ do |event_type|
  if event_type.downcase == "encounter"
      @encounter_event = create_basic_event("encounter", get_unique_name(1), @form.diseases.first.disease_name.strip,  Place.unassigned_jurisdiction.short_name)
    @event = @encounter_event.parent_event
  elsif event_type.downcase == "contact"
      @contact_event = create_basic_event("contact", get_unique_name(1), @form.diseases.first.disease_name.strip,  Place.unassigned_jurisdiction.short_name)
    @event = @contact_event.parent_event
  else
    @event = create_basic_event(event_type, get_unique_name(1), @form.diseases.first.disease_name.strip,  Place.unassigned_jurisdiction.short_name)
  end
end

When /^I navigate to the new morbidity event page and start a event with the form's disease$/ do
  @browser.open "/trisano/cmrs/new"
  add_demographic_info(@browser, { :last_name => get_unique_name })
  @browser.type('morbidity_event_first_reported_PH_date', Date.today)
  @browser.select('morbidity_event_disease_event_attributes_disease_id', @form.diseases.first.disease_name)
end


Given /^a (.+) event with a form with repeating core fields$/ do |event_type|
  Given "a published form with repeating core fields for a #{event_type} event"
  And   "a basic #{event_type} event with the form's disease"
end

Given /^a (.+) event with a morbidity and assessment event form with repeating core fields$/ do |event_type|
  Given "a published form with repeating core fields for a morbidity_and_assessment event"
  And   "a basic #{event_type} event with the form's disease"
end

When /^I change the disease to (.+) the published form$/ do |match_not_match|
  click_core_tab(@browser, "Clinical")
  if match_not_match == "match"
    disease_name = @published_form.diseases.first.disease_name
  elsif match_not_match == "not match"
    # Don't want to use Hep B Pregnancy event because it has disease specific fields
    disease = Disease.find(:first, :conditions => ["disease_name != ? AND disease_name != ?", @published_form.diseases.first.disease_name, "Hepatitis B Pregnancy Event"])
    disease_name = disease.disease_name
  else
    raise "Unexpected syntax: #{match_not_match}"
  end
  
  if @published_form.event_type.include?("morbidity_and_assessment_event")
    key = @published_form.event_type.gsub("morbidity_and_assessment_event", @event.class.name.underscore)
  else
    key = @published_form.event_type
  end
  @browser.select("//select[@id='#{key}_disease_event_attributes_disease_id']", disease_name)
end

When /^I print the (.+) event$/ do |event_type|
  event = case event_type
            when "morbidity","assessment","morbidity and assessment"
              @event
            when "contact"
              @contact_event
            when "encounter"
              raise "Printing is not supported for encounter events."
  end

  event_path = url_for({
      :controller => event.attributes["type"].tableize,
      :id => event.id,
      :action => :show,
      :format => "print",
      :commit => "Print",
      "print_options[]" => "All",
      :only_path => true
    })
  @browser.open "/trisano" + event_path
  @browser.wait_for_page_to_load
end

When /^I fill in "(.+)" with an invalid date$/ do |label|
  invalid_date = 1.year.from_now.to_date.to_formatted_s
  When "I fill in \"#{label}\" with \"#{invalid_date}\""
end

When /^I fill in "(.+)" with a valid date$/ do |label|
  valid_date = 1.day.ago.to_date.to_formatted_s
  When "I fill in \"#{label}\" with \"#{valid_date}\""
end

When /^the (.+) tab should be highlighted in red$/ do |tab|
  @browser.get_xpath_count("//a[@href='##{tab.downcase}_tab'][contains(@style,'color: red')]").should be_equal(1), "Expected #{tab} to be highlighted in red."
end

When /^I answer all core field config repeating questions$/ do
  # Also fill in one address field so the address will show up in show mode
  html_source = @browser.get_html_source
  @core_fields ||= CoreField.all(:conditions => ['event_type = ? AND fb_accessible = ? AND disease_specific = ? AND repeater = ?', @form.event_type, true, false, true])
  raise "No core fields found" if @core_fields.empty?
  @core_fields.each do |core_field|
    if core_field.key.include?("morbidity_and_assessment_event")
      key = core_field.key.gsub("morbidity_and_assessment_event", @event.class.name.underscore)
    else
      key = core_field.key
    end
    answer_investigator_question(@browser, "#{key} before?", "#{key} before answer", html_source).should be_true
    answer_investigator_question(@browser, "#{key} after?", "#{key} after answer", html_source).should be_true
  end

  # A Lab and a Test type is a required field to save a lab so we must fill it out any time we answer all repeaters
  And  "I enter the following lab results for the \"Acme Lab\" lab:", table([
    %w( test_type ),
    %w( TriCorder )
  ])
end

Given /^I have required repeater core field prerequisites$/ do
  And "a lab named \"Acme Lab\""
  And "a lab named \"LabCo Lab\""
  And "a lab test type named \"TriCorder\""
  And "a lab test type named \"CAT Scan\""
end

When /^I navigate to the form's builder page$/ do
  @browser.open "/trisano" + builder_path(@form)
end

Then /^I should see (\d+) instances of the repeater core field config questions$/ do |expected_count|
  # We want to use body_text here because the JavaScript links contain template code
  # which have the question text in them, which throws off the count...not that we want to 
  # count templates anyway.
  html_source = @browser.get_body_text
  @core_fields ||= CoreField.all(:conditions => ['event_type = ? AND fb_accessible = ? AND disease_specific = ? AND repeater = ?', @form.event_type, true, false, true])
  @core_fields.count.should_not be_equal(0), "Didn't find any lab core fields."
  @core_fields.each do |core_field|
    if core_field.key.include?("morbidity_and_assessment_event")
      key = core_field.key.gsub("morbidity_and_assessment_event", @event.class.name.underscore)
    else
      key = core_field.key
    end
    html_source.scan("#{key} before?").count.should be_equal(expected_count.to_i), "Could not find #{expected_count} instances of before question for #{key}" 
    html_source.scan("#{key} after?").count.should be_equal(expected_count.to_i), "Could not find #{expected_count} instances of after question for #{key}" 
  end
end

Then /^I should see (\d+) instances of answers to the repeating core field config questions$/ do |expected_count|
  html_source = @browser.get_html_source
  @core_fields ||= CoreField.all(:conditions => ['event_type = ? AND fb_accessible = ? AND disease_specific = ? AND repeater = ?', @form.event_type, true, false, true])
  @core_fields.count.should_not be_equal(0), "Didn't find any core fields."
  @core_fields.each do |core_field|
    if core_field.key.include?("morbidity_and_assessment_event")
      key = core_field.key.gsub("morbidity_and_assessment_event", @event.class.name.underscore)
    else
      key = core_field.key
    end
    html_source.scan("#{key} before answer").count.should be_equal(expected_count.to_i), "Could not find #{expected_count} instances of before answer for #{key}" 
    html_source.scan("#{key} after answer").count.should be_equal(expected_count.to_i), "Could not find #{expected_count} instances of after answer for #{key}" 
  end
end

When /^I create (\d+) new instances of all (.+) event repeaters$/ do |count, event_type|
    count.to_i.times do
      

      unless event_type == "encounter"
        click_core_tab(@browser, "Demographics")
        And  "I click the \"Add a Telephone\" link and don't wait"
        And  "I click the \"Add an Email Address\" link and don't wait"
      end

      click_core_tab(@browser, "Clinical")
      unless event_type == "encounter"
        And  "I click the \"Add a Hospitalization Facility\" link and don't wait"
      end
      And  "I click the \"Add a Treatment\" link and don't wait"
    
      When "I enter the following lab results for the \"Acme Lab\" lab:", table([
              %w(test_type),
              %w(TriCorder),
              ["CAT Scan"]])
    end
end

When /^I answer (\d+) instances of all repeater questions$/ do |count|
  html_source = @browser.get_html_source
  @core_fields ||= CoreField.all(:conditions => ['event_type = ? AND fb_accessible = ? AND disease_specific = ? AND repeater = ?', @form.event_type, true, false, true])
  raise "No core fields found" if @core_fields.empty?
  @core_fields.each do |core_field|
    if core_field.key.include?("morbidity_and_assessment_event")
      key = core_field.key.gsub("morbidity_and_assessment_event", @event.class.name.underscore)
    else
      key = core_field.key
    end
    count.to_i.times do |i|
      answer_investigator_question(@browser, "#{key} before?", "#{key} before answer #{i}", html_source, i)
      answer_investigator_question(@browser, "#{key} after?", "#{key} after answer #{i}", html_source, i)
    end
  end
end

When /^I answer (\d+) instances of all repeater section questions$/ do |count|
  html_source = @browser.get_html_source
  count.to_i.times do |i|
    answer_investigator_question(@browser, "#{@section_element.name} question?", "#{@section_element.name} answer #{i}", html_source, i)
  end
end

When /^I create (\d+) new instances of all section repeaters$/ do |count|
  count.to_i.times do
    And  "I click the \"Add another #{@section_element.name} section\" link and don't wait"
  end
end

Then /^I should see (\d+) instances of the repeater section questions$/ do |expected_count|
  # We want to use body_text here because the JavaScript links contain template code
  # which have the question text in them, which throws off the count...not that we want to 
  # count templates anyway.
  html_source = @browser.get_body_text
  actual_count = html_source.scan("#{@section_element.name} question?").count
  actual_count.should be_equal(expected_count.to_i), "Expected #{expected_count} instances of '#{@section_element.name} question?', got #{actual_count}." 
end

Then /^I should see (\d+) instances of answers to the repeating section questions$/ do |count|
  html_source = @browser.get_html_source
  count.to_i.times do |i|
    actual_count = html_source.scan("#{@section_element.name} answer #{i}").count
    actual_count.should be_equal(1), "Expected 1 instances of '#{@section_element.name} answer #{i}', got #{actual_count}."
  end
end
