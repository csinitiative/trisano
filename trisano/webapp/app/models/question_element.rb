# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

class QuestionElement < FormElement
  has_one :question, :foreign_key => "form_element_id", :dependent => :destroy
  belongs_to :export_column

  attr_accessor :parent_element_id
  
  validates_associated :question
  validates_presence_of :question
  
  def save_and_add_to_form
    unless export_column.nil?
      return nil if export_column.data_type.blank?
      question_instance.data_type = export_column.data_type
      question_instance.size = export_column.length_to_output
    end
    
    self.question = question_instance
    super do
      build_cdc_value_set unless export_column.nil?
    end
  end

  # Used to process follow-ups to questions in a form, not follow-ups to core
  # fields. For core-field processing, see FollowUpElement#process_condition
  def process_condition(answer, event_id, form_elements_cache=nil)
    result = nil
    potential_follow_ups = retrieve_follow_ups(form_elements_cache)
    condition = parse_condition_from_answer(answer)
    
    potential_follow_ups.each do |follow_up|
      if (FormElement.normalize_condition(follow_up.condition) == FormElement.normalize_condition(condition))
        result = follow_up
      else
        FormElement.delete_answers_to_follow_ups(event_id, follow_up)
      end
    end
    
    result
  end

  def question_instance
    @question_instance || question
  end
  
  def question_attributes=(question_attributes)
    if new_record?
      @question_instance = Question.new(question_attributes)
    else
      question_instance.update_attributes(question_attributes)
    end
  end

  def is_multi_valued?
    question_instance.data_type == :drop_down || question_instance.data_type == :radio_button || question_instance.data_type == :check_box
  end

  def is_multi_valued_and_empty?
    is_multi_valued? && (children_count_by_type("ValueSetElement") == 0)
  end
  
  def build_cdc_value_set
    return unless ((export_column.data_type == "radio_button") or (export_column.data_type == "drop_down") or (export_column.data_type == "check_box"))
    
    value_set = ValueSetElement.create({
        :form_id => self.form_id,
        :tree_id => self.tree_id,
        :export_column_id => export_column.id,
        :name => "#{export_column.export_name.export_name} #{export_column.export_column_name}",
      })
    
    self.add_child(value_set)

    if (export_column.data_type == "drop_down")
      blank_value_element = ValueElement.create({
          :form_id => self.form_id,
          :tree_id => self.tree_id,
          :name => ""
        })
      value_set.add_child(blank_value_element)
    end

    export_column.export_conversion_values.each do |value|
      value_element = ValueElement.create({
          :form_id => self.form_id,
          :tree_id => self.tree_id,
          :name => value.value_from,
          :export_conversion_value_id => value.id
        })
      value_set.add_child(value_element)
    end
  end

  private

  # Follow ups can come out of the form element cache, if one has already
  # been initialized, otherwise, go to the database.
  def retrieve_follow_ups(form_elements_cache)
    if form_elements_cache.nil?
      return self.children_by_type("FollowUpElement")
    else
      return form_elements_cache.children_by_type("FollowUpElement", self)
    end
  end

  # An answer can either be an instance of Answer, or just a string from a
  # parameter. Return the
  def parse_condition_from_answer(answer)
    if (answer.is_a? Answer)
      return answer.text_answer
    else
      return answer[:response]
    end
  end
  
end
