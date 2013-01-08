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



When /^I print the morbidity event with "([^\"]*)"$/ do |option|
  visit cmr_path(@event, :format => :print, :print_options => [option])
end

Then /^I should see "([^\"]*)" under contact reports$/ do |value|
  response.should have_xpath("//div[@id='contact-reports']//span[contains(text(),'#{value}')]")
  response.should have_xpath("//div[@id='contacts']//span[contains(text(),'#{value}')]")
end

Then /^I should not see "([^\"]*)" under contact reports$/ do |value|
  response.should_not have_xpath("//div[@id='contact-reports']//span[contains(text(),'#{value}')]")
  response.should_not have_xpath("//div[@id='contacts']//span[contains(text(),'#{value}')]")
end

When /^I choose to print "([^\"]*)" data$/ do |section|
  check "print_#{section.downcase}" 
end

Then /^I should see the following sections:$/ do |sections|
  sections.rows.each do |section|
    response.should have_selector("##{section.first.downcase}")
  end
end

Then /^I should not see the following sections$/ do |sections|
  sections.rows.each do |section|
    response.should_not have_selector("##{section.first.downcase}")
  end
end

Then /^section headers should contain "([^\"]*)"$/ do |value|
  assert_tag(:tag => 'span',
    :attributes => { :class => "section-header" },
    :child => /#{value}/
  )
end

