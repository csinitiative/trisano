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

  after_create :create_answers_for_repeaters

  def create_answers_for_repeaters
    Answer.transaction do
      if repeaters = form.repeater_elements
        repeaters.each do |repeater|

          repeater_records = collect_records_from_core_path(:event => event, :element => repeater)
          question_elements_for_repeater = form.form_element_cache.all_children_by_type("QuestionElement", repeater)

          question_elements_for_repeater.each do |question_element|
            repeater_records.each do |repeater_record|

              answer_attributes = {:question_id => question_element.question.id, 
                                   :event_id => event.id,
                                   :repeater_form_object_type => repeater_record.class.name,
                                   :repeater_form_object_id => repeater_record.id}
              answer_object = event.get_or_initialize_answer(answer_attributes)
              answer_object.save if answer_object.new_record?

            end
          end #questions_for_repater


        end # repeaters.each
      end # if repeaters
    end #transaction
  end
end
