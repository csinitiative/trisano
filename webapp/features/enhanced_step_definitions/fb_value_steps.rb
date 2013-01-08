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


Given /^that form has multiple questions with values on value sets$/ do
  value_set_name = "Y/N/U"
  values = [["Yes", "1"], ["No", "2"], ["Unknown", "3"]]

  first_radio_button_question = create_question_on_form(@form, { :question_text => "first radio?", :short_name => "first_radio", :data_type => "radio_button" })
  second_radio_button_question = create_question_on_form(@form, { :question_text => "second radio?", :short_name => "second_radio", :data_type => "radio_button" })

  first_check_box_question = create_question_on_form(@form, { :question_text => "first check box?", :short_name => "first_check_box", :data_type => "check_box" })
  second_check_box_question = create_question_on_form(@form, { :question_text => "second check box?", :short_name => "second_check_box", :data_type => "check_box" })


  first_drop_down_question = create_question_on_form(@form, { :question_text => "first drop down?", :short_name => "first_drop_down", :data_type => "drop_down" })
  second_drop_down_question = create_question_on_form(@form, { :question_text => "second drop down?", :short_name => "second_drop_down", :data_type => "drop_down" })

  [first_radio_button_question, second_radio_button_question,
    first_check_box_question, second_check_box_question,
    first_drop_down_question, second_drop_down_question
  ].each do |question|
    add_value_set_to_question(question, value_set_name, values)
  end
end


When /^I answer all of the first questions with "([^\"]*)"$/ do |answer|
  answer_radio_investigator_question(@browser, "first radio?", answer).should be_true
  answer_check_investigator_question(@browser, "first check box?", answer).should be_true
  answer_multi_select_investigator_question(@browser, "first drop down?", answer).should be_true
end

When /^I answer all of the second questions with "([^\"]*)"$/ do |answer|
  answer_radio_investigator_question(@browser, "second radio?", answer).should be_true
  answer_check_investigator_question(@browser, "second check box?", answer).should be_true
  answer_multi_select_investigator_question(@browser, "second drop down?", answer).should be_true
end

Then /^all answers answered "([^\"]*)" should have the code "([^\"]*)"$/ do |answer, code|
  @event.reload
  @event.answers.find_all { |event_answer| event_answer.text_answer.include?(answer) }.each do |a|
    a.code.include?(code).should be_true
  end

end

Then /^there should be ([^\"]*) answers answered "([^\"]*)"$/ do |count, answer|
  @event.reload
  @event.answers.find_all { |event_answer| event_answer.text_answer.include?(answer) }.size.should == count.to_i
end

When /^I check all check boxes$/ do
  # Only check the ones that aren't already checked, otherwise you are unchecking them
  answer_check_investigator_question(@browser, "first check box?", "Unknown").should be_true
  answer_check_investigator_question(@browser, "second check box?", "Yes").should be_true
  answer_check_investigator_question(@browser, "second check box?", "Unknown").should be_true
end

Then /^both check box questions should have all codes$/ do
  @event.reload
  check_box_answers = @event.answers.find_all { |event_answer| event_answer.text_answer.include?("Unknown") }
  check_box_answers.size.should == 2
  check_box_answers.each do |answer|
    answer.code.include?("1").should be_true
    answer.code.include?("2").should be_true
    answer.code.include?("3").should be_true
  end
end




