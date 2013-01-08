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
Given /^I go to the core fields admin page$/ do
  @browser.open "/trisano/core_fields"
end

When /^I hide a core field$/ do
  @test_field_href = @browser.get_eval(<<-JS)
    var aj = selenium.browserbot.getCurrentWindow().$j;
    var testField = aj('.button a.hide').first();
    var testFieldHref = testField.attr('href');
    testField.click();
    testFieldHref
  JS
  @browser.wait_for_condition(<<-JS)
    var aj = selenium.browserbot.getCurrentWindow().$j;
    aj('.button a[href="#{@test_field_href}"]').first().hasClass('display');
  JS
end

Then /^the hide button should change to a display button$/ do
  @browser.get_eval(<<-JS).should == "true"
    var aj = selenium.browserbot.getCurrentWindow().$j;
    aj('.button a[href="#{@test_field_href}"]').first().hasClass('display');
  JS
end

When /^I re\-display the core field$/ do
  @browser.run_script(<<-JS)
    $j('.button a[href="#{@test_field_href}"]').first().click();
  JS
  @browser.wait_for_condition(<<-JS)
    var aj = selenium.browserbot.getCurrentWindow().$j;
    aj('.button a[href="#{@test_field_href}"]').first().hasClass('hide');
  JS
end

Then /^the display button should change to a hide button$/ do
  @browser.get_eval(<<-JS).should == "true"
    var aj = selenium.browserbot.getCurrentWindow().$j;
    aj('.button a[href="#{@test_field_href}"]').first().hasClass('hide');
  JS
end

When /^I apply this configuration to "([^\"]*)"$/ do |disease_name|
  @other_disease = Disease.find_by_disease_name(disease_name)
  @browser.click("css=button.apply_to_diseases")
  @browser.wait_for_condition(<<-JS)
    var aj = selenium.browserbot.getCurrentWindow().$j;
    aj('label[for="other_disease_#{@other_disease.id}"]').size() > 0;
  JS
  @browser.run_script(<<-JS)
    $j('input#other_disease_#{@other_disease.id}').click();
    $j('.ui-button').last().click();
  JS
  @browser.wait_for_page_to_load
end

Then /^the "([^\"]*)" disease core field is hidden$/ do |disease_name|
  @disease = Disease.find_by_disease_name(disease_name)
  new_href = @test_field_href.gsub(/diseases\/\d+/, "diseases/#{@disease.id}")
  @browser.get_eval(<<-JS).should == "true"
    var aj = selenium.browserbot.getCurrentWindow().$j;
    aj('.button a[href="#{new_href}"]').hasClass('display');
  JS
end
