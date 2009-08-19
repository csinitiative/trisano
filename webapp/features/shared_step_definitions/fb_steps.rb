# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

#
# Form-builder steps that can be utilized by standard or enhanced UATs
#

# Generic form-creation steps that vary in what you can provide if randomly
# generated names and diseases will do.

Given(/^a (.+) event form exists$/) do |event_type|
  unique_form_name = get_unique_name(3)
  @form = create_form(event_type, unique_form_name, unique_form_name, get_random_disease)
end

Given(/^a (.+) event form exists for the disease (.+)$/) do |event_type, disease|
  unique_form_name = get_unique_name(3)
  @form = create_form(event_type, unique_form_name, unique_form_name, disease)
end

Given(/^a (.+) event form exists for the disease (.+) with the name (.+) \((.+)\)$/) do |event_type, disease, form_name, form_short_name|
  @form = create_form(event_type, form_name, form_short_name, disease)
end

Given(/^that form is published$/) do
  @published_form = @form.publish
  @published_form.should_not be_nil
end

#
# Published form helpers.
#
# Note: Any questions added after will not be published unless another step publishes the form again
#

Given(/^a published form exists with the name (.+) \((.+)\) for a (.+) with the disease (.+)$/) do |form_name, form_short_name, event_type, disease|
  @form = create_form(event_type, form_name, form_short_name, disease)
  @published_form = @form.publish
  @form
end

Given(/^a published form exists with the name (.+) \((.+)\) for a (.+) with any disease$/) do |form_name, form_short_name, event_type|
  @form = create_form(event_type, form_name, form_short_name, get_random_disease)
  @published_form = @form.publish
  @form
end

#
# Question helpers
#

Given(/^that form has (.+) questions$/) do |number_of_questions|
  number_of_questions.to_i.times do |question|
    question_element = QuestionElement.new({
        :parent_element_id => @form.investigator_view_elements_container.children[0].id,
        :question_attributes => {
          :question_text =>  "#{get_unique_name(3)} #{question}",
          :data_type => "single_line_text",
          :short_name => get_unique_name(2)
        }
      })
    question_element.save_and_add_to_form
  end
end

Given(/^that form has one question on the default view$/) do
  @question_element = QuestionElement.new({
      :parent_element_id => @form.investigator_view_elements_container.children[0].id,
      :question_attributes => {
        :question_text =>  get_unique_name(3),
        :data_type => "single_line_text",
        :short_name => get_unique_name(2)
      }
    })
  @question_element.save_and_add_to_form
end

Given(/^that form has a question with the short name \"(.+)\"$/) do |short_name|
  @question_element = QuestionElement.new({
      :parent_element_id => @form.investigator_view_elements_container.children[0].id,
      :question_attributes => {
        :question_text => "I have a short name?",
        :data_type => "single_line_text",
        :short_name => short_name
      }
    })
  @question_element.save_and_add_to_form
end


