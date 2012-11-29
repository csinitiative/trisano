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

class FormReference < ActiveRecord::Base
  include FormBuilderDslHelper

  belongs_to :event
  belongs_to :form
  has_many :answers, :through => :event, :dependent => :destroy

  after_create :create_answers_for_repeaters
  after_destroy :destroy_answers

  def destroy_answers
    question_ids = form.questions.map(&:id)
    answers = Answer.find(:all, :conditions => ["question_id in (?) and event_id = ?", question_ids, event.id])
    answers.map(&:destroy)
  end

  def create_answers_for_repeaters
    Answer.transaction do
      if repeater_form_elements = form.repeater_elements
        repeater_form_elements.each do |repeater_form_element|

          repeater_form_object_key = repeater_form_element.core_field.key
          method_array = core_path_to_method_string(repeater_form_object_key, event.class.name.underscore).split(".")
          method_array.pop #take off the last element, so we get the class, not the field

          repeater_records = eval_core_path(:object => event, :method_array => method_array)
          # No need to create answers for records that don't exist!
          return nil if repeater_records.nil?

          question_elements_for_repeater = form.form_element_cache.all_children_by_type("QuestionElement", repeater_form_element)

          repeater_attributes = {
            :new_repeater_radio_buttons => {},
            :new_repeater_checkboxes => {},
            :new_repeater_answer => []
          } 

          question_elements_for_repeater.each do |question_element|

            case question_element.question.data_type
            when :radio_button
              repeater_attributes[:new_repeater_radio_buttons][question_element.question.id] = {
                :event_id => event.id,
                :radio_button_answer => [],
                :export_conversion_value_id => "",
                :code => ""
              } 

            when :checkbox
              repeater_attributes[:new_repeater_checkboxes][question_element.question.id] = {
                :event_id => event.id,
                :check_box_answer => [],
                :code => ""
              }

            else
              repeater_attributes[:new_repeater_answer] << {
                :event_id => event.id,
                :question_id => question_element.question.id,
                :text_answer => ""
              }

            end #case


          end #questions_for_repater

          repeater_records.each do |repeater_record|
            repeater_record.update_attributes(repeater_attributes) 
          end
        end # each form element
      end # if repeaters
    end #transaction
  end
end
