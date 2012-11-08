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

          repeater_form_object_key = repeater_form_element.core_field.repeater_parent_key
          method_array = core_path_to_method_array(repeater_form_object_key, event.class.name.underscore)

          repeater_records = process_core_path(:object => event, :method_array => method_array)
          question_elements_for_repeater = form.form_element_cache.all_children_by_type("QuestionElement", repeater_form_element)

          question_elements_for_repeater.each do |question_element|
            repeater_records.each do |repeater_record|
      
              # It is critical the text_answer be initialized as an empty string as it would be
              # if entered from a form
              answer_attributes = {:question_id => question_element.question.id, 
                                   :event_id => event.id,
                                   :repeater_form_object_type => repeater_record.class.name,
                                   :repeater_form_object_id => repeater_record.id,
                                   :text_answer => ""}
              answer_object = event.get_or_initialize_answer(answer_attributes)
              answer_object.save if answer_object.new_record?

            end
          end #questions_for_repater


        end # repeaters.each
      end # if repeaters
    end #transaction
  end
end
