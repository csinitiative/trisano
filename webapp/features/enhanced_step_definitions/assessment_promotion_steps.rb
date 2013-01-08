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
When /^I promote the assessment to a morbidity event$/ do
 When "I click the \"Promote to CMR\" link and accept the confirmation"

  # we want to make available the promoted event at a later time
  # but only if the promotion was successful
   #
   # get_location returns "http://localhost:8080/trisano/cmrs/849"
   # cmr_url returns ""http://www.example.com/cmrs/849" 
   # use cmr_path to check for partial match
  if @browser.get_location.include?(cmr_path(@event))
    #Then reload the event to make it available for other steps
    @promoted_event = MorbidityEvent.find(@event.id)
  end
end

Then /^I should see all of the promoted core field config questions$/ do
  html_source = @browser.get_html_source
  @promoted_core_fields ||= CoreField.all(:conditions => ['event_type = ? AND fb_accessible = ? AND disease_specific = ?', @promoted_event.type.underscore, true, false])
  @promoted_core_fields.each do |core_field|
    raise "Could not find before config for #{core_field.key}" if html_source.include?("#{core_field.key} before?") == false
    raise "Could not find after config for #{core_field.key}" if html_source.include?("#{core_field.key} after?") == false
  end
end

Then /^I should see all promoted core field config answers$/ do
  html_source = @browser.get_html_source
  @promoted_core_fields ||= CoreField.all(:conditions => ['event_type = ? AND fb_accessible = ? AND disease_specific = ?', @promoted_event.type.underscore, true, false])
  @promoted_core_fields.each do |core_field|
    raise "Could not find before answer for #{core_field.key}" if html_source.include?("#{core_field.key} before answer") == false
    raise "Could not find after answer for #{core_field.key}" if html_source.include?("#{core_field.key} after answer") == false
  end
end

Given /^I don\'t see any of the promoted core follow up questions$/ do
  html_source = @browser.get_html_source
  @promoted_core_fields ||= CoreField.all(:conditions => ['event_type = ? AND can_follow_up = ? AND disease_specific = ?', @promoted_event.type.underscore, true, false])
  @promoted_core_fields.each do |core_field|
    raise "Should not not find #{core_field.key}" if html_source.include?("#{core_field.key} follow up?") == true
  end
end
