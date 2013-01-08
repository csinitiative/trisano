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

Then /^I should see all of the core field config questions$/ do
  label_text = Nokogiri::HTML(response.body).xpath("//label").text
  CoreField.all(:conditions => ['event_type = ? and fb_accessible = true and disease_specific != true and repeater = false', @form.event_type]).each do |core_field|
    label_text.should contain("#{core_field.key} before?"), "Expected to see #{core_field.key} before?"
    label_text.should contain("#{core_field.key} after?"), "Expected to see #{core_field.key} after?"
  end
end

Then /^I should see all of the promoted core field config questions$/ do
  raise "No promoted event found" if @promoted_event.nil?
  label_text = Nokogiri::HTML(response.body).xpath("//label").text
  CoreField.all(:conditions => ['event_type = ? and fb_accessible = true and disease_specific != true and repeater = false', @form.event_type]).each do |core_field|
    promoted_core_field_key = core_field.key.gsub(@form.event_type, @promoted_event.class.name.underscore)
    label_text.should contain("#{promoted_core_field_key} before?")
    label_text.should contain("#{promoted_core_field_key} after?")
  end
end

When /^I answer all core field config questions$/ do
  CoreField.all(:conditions => ['event_type = ? and fb_accessible = true and disease_specific != true and repeater = false', @form.event_type]).each do |core_field|
    puts "Answering #{core_field.key}"
    fill_in("#{core_field.key} before?", :with => "#{core_field.key} before answer")
    fill_in("#{core_field.key} after?", :with => "#{core_field.key} after answer")
  end
end

Then /^I should see all core field config answers$/ do
  divs_text =  Nokogiri::HTML(response.body).css("div").text
  CoreField.all(:conditions => ['event_type = ? and fb_accessible = true and disease_specific != true and repeater = false', @form.event_type]).each do |core_field|
    puts core_field.key
    divs_text.should contain("#{core_field.key} before answer"), "Expeted to see #{core_field.key} before answer"
    divs_text.should contain("#{core_field.key} after answer"), "Expeted to see #{core_field.key} answer answer"
  end
end

Then /^I should see all promoted core field config answers$/ do
  raise "No promoted event found" if @promoted_event.nil?
  divs_text =  Nokogiri::HTML(response.body).css("div").text
  CoreField.all(:conditions => ['event_type = ? and fb_accessible = true and disease_specific != true and repeater = false', @form.event_type]).each do |core_field|
    promoted_core_field_key = core_field.key.gsub(@form.event_type, @promoted_event.class.name.underscore)
    divs_text.should contain("#{promoted_core_field_key} before answer")
    divs_text.should contain("#{promoted_core_field_key} after answer")
  end
end
