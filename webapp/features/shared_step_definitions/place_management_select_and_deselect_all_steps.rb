# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

Given(/^three similar labs exist with "([^\"]*)" in the name$/) do |name|
  @first_place = Factory.create(:place, :name => "#{name}-#{get_unique_name(2)}")
  @first_place_entity = Factory.create(:place_entity, :place => @first_place)
  @second_place = Factory.create(:place, :name => "#{name}-#{get_unique_name(2)}")
  @second_place_entity = Factory.create(:place_entity, :place => @second_place)
  @third_place = Factory.create(:place, :name => "#{name}-#{get_unique_name(2)}")
  @third_place_entity = Factory.create(:place_entity, :place => @third_place)
end

When(/^I click merge for the first lab$/) do
  @browser.click("merge_#{@first_place_entity.id}")
  @browser.wait_for_page_to_load($load_time)
end

When(/^I click the select-all option$/) do
  @browser.click("link=All")
  sleep 2
end

When(/^I click the select-none option$/) do
  @browser.click("link=None")
  sleep 2
end

Then(/^all merge check boxes should be selected$/) do
  @browser.get_eval("assertion = true; selenium.browserbot.getCurrentWindow().$$('#merge_form input.merge_check_box').each(function(box){ if (box.checked==false) {assertion = false}}); assertion;").should be_true
end

Then(/^all merge check boxes should not be selected$/) do
  @browser.get_eval("assertion = true; selenium.browserbot.getCurrentWindow().$$('#merge_form input.merge_check_box').each(function(box){ if (box.checked==true) {assertion = false}}); assertion;").should be_true
end
