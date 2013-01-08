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

class FollowUpElement < FormElement
  
  attr_accessor :core_data, :event_type
  
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

  def condition_match?(string_condition)
    return if self.condition.nil? || string_condition.nil?
    
    # We split on \n in order to handle answer output from checkboxes
    # Then check if any of the split options match the condition
    string_condition.split("\n").any? do |other_condition|
      self.condition.strip.downcase == other_condition.strip.downcase
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

  # Used to process follow-ups to core-fields in a form, not follow-ups to standard
  # question elements. For question-element processing, see QuestionElement#process_condition
  def self.process_core_condition(params, options={})
    result = []
    event = Event.find(params[:event_id])

    event.form_references.each do |form_reference|
      form_reference.form.form_element_cache.all_follow_ups_by_core_path(params[:core_path]).each do |follow_up|
        if (follow_up.condition_match?(params[:response]))
          # Debt: The magic container for core follow ups needs to go probably
          result << ["show", follow_up]
        else
          result << ["hide", follow_up]
          
          unless (params[:event_id].blank?)
            FormElement.delete_answers_to_follow_ups(params[:event_id], follow_up) if options[:delete_irrelevant_answers]
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
