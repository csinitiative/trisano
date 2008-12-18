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

class FollowUpElement < FormElement
  
  attr_accessor :parent_element_id, :core_data, :event_type
  
  validates_presence_of :condition
  validates_presence_of :core_path, :if => Proc.new {|follow_up| follow_up.core_data == "true" }
  
  def save_and_add_to_form
    if self.valid?
      parse_and_assign_condition(condition_id, condition)
      super
    end
  end
  
  def update_core_follow_up(params)
    begin
      transaction do
        self.attributes = params
        if parse_and_assign_condition(params["condition_id"], params["condition"])
          self.save
        else
          return nil
        end
        validate_form_structure
        return true
      end
    rescue
        return nil
    end
  end
  
  def self.condition_string_from_code(code_id)
    code = ExternalCode.find(code_id)
    return "Code: #{code.code_description} (#{code.code_name})"
  rescue
    return nil
  end
  
  def condition_id=(condition_id)
    @condition_id = condition_id
  end
  
  def condition_id
    @condition_id
  end
  
  def self.process_core_condition(params)
    result = []
    investigation_forms = []
    
    event = Event.find(params[:event_id])

    if event.form_references.blank?
      investigation_forms = event.get_investigation_forms
    else
      event.form_references.each do |form_reference|
        investigation_forms << form_reference.form
      end
    end

    investigation_forms.each do |form|
      form.form_element_cache.all_follow_ups_by_core_path(params[:core_path]).each do |follow_up|
        if (params[:response] == follow_up.condition)
          # Debt: The magic container for core follow ups needs to go probably
          result << ["show", follow_up]
        else
          result << ["hide", follow_up]
          
          unless (params[:event_id].blank?)
            # Debt: We could add a method that does this against the cache
            question_elements_to_delete = QuestionElement.find(:all, :include => :question,
              :conditions => ["lft > ? and rgt < ? and tree_id = ?", follow_up.lft, follow_up.rgt, follow_up.tree_id])
              
            question_elements_to_delete.each do |question_element|
              answer = Answer.find_by_event_id_and_question_id(params[:event_id], question_element.question.id)
              answer.destroy unless answer.nil?
            end
          end
        end
      end
    end

    result
  end
  
  private
  
  # This method accounts for the different field/value combinations
  # that can result from the submission of the type-ahead field. The
  # condition or condition_id can have different values depending on
  # how the user modifies the input field and whether a validation error
  # occurred on an attempted submission of the follow-up form.
  def parse_and_assign_condition(condition_id, condition)
    unless condition_id.blank?
      if (condition_id.to_i != 0)
        self.condition = condition_id
        self.is_condition_code = true
      else
        parse_and_assign_condition_from_string(condition_id)
      end
    else
      parse_and_assign_condition_from_string(condition)
    end
    return true
  rescue
    return false
  end
  
  def parse_and_assign_condition_from_string(condition_value)
    begin
      condition_value = condition_value.strip
      if (condition_value.index("Code: ") == 0)
        code_description_end = condition_value.index("(") - 2
        code_description = condition_value[6..code_description_end]
        code_name_end = condition_value.index(")") - 1
        code_name = condition_value[code_description_end+3..code_name_end]
        code = ExternalCode.find_by_code_name_and_code_description(code_name, code_description)
        raise "Code parsed from condition can't be found" if code.nil?
        self.condition = code.id
        self.is_condition_code = true
      else
        raise "Condition doesn't begin with the magic string"
      end
    rescue
      self.condition = condition_value
      self.is_condition_code = false
    end
  end
  
  
end
