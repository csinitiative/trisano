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

class QuestionElement < FormElement
  include Trisano::FormElement::ShortName

  has_one :value_set_element, :class_name => "ValueSetElement", :foreign_key => 'parent_id', :include => [:value_elements], :dependent => :destroy
  belongs_to :export_column
  belongs_to :repeater_form_object, :polymorphic => true

  validates_presence_of :question

  accepts_nested_attributes_for :question

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
  # fields. For core-field processing, see FollowUpElement#process_core_condition
  def process_condition(answer, event_id, options={})
    results = []
    potential_follow_ups = retrieve_follow_ups(options[:form_elements_cache])
    condition = parse_condition_from_answer(answer)

    potential_follow_ups.each do |follow_up|
      if (follow_up.condition_match?(condition))
        results << follow_up
      else
        FormElement.delete_answers_to_follow_ups(event_id, follow_up) if options[:delete_irrelevant_answers]
      end
    end

    results
  end
  
  def question_instance
    @question_instance || question
  end

  def is_multi_valued?
    question_instance.is_multi_valued?
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

  def validate
    if question_element_state.nil?
      self.errors.add_to_base(:invalid_state)
    else
      validate_question_short_name_uniqueness unless self.question_element_state == :copying_question_to_library
    end
  end

  # Debt. There's gotta be a better way to do all of this.
  def question_element_state
    if (self.new_record? && !self.parent_element_id.blank?)
      return :new_question_on_form
    elsif (self.new_record? && self.form_id.blank? && self.parent_element_id.blank?)
      return :copying_question_to_library
    elsif (self.new_record? && !self.form_id.blank? && self.parent_element_id.blank?)
      return :copying_question_from_library
    elsif (!self.new_record? && !self.form_id.nil?)
      return :edit_question_on_form
    end
  end

  def copying_question_from_library?
    question_element_state == :copying_question_from_library
  end

  def short_name_editable?
    return true if form.nil?
    most_recent_version = form.most_recent_version
    return true if most_recent_version.nil?
    return false if (most_recent_version.created_at > self.created_at)
    return true
  end

  def copy_from_library(library_element, options = {})
    library_element.question = self.question.clone
    super
  end

  def copy(options = {})
    dupe = super(options)
    dupe.question = question.clone
    if options[:replacements].try(:[], question.id.to_s)
      options[:replacements][question.id.to_s].each do |k, v|
        dupe.question.send(k + "=", v)
      end
    end
    dupe
  end

  def copy_children(options={})
    children.each do |child|
      child.question = self.question.clone
      child.copy_with_children(options)
    end
  end

  def can_receive_value_set?
    begin
      not children.any? { |child| child.is_a?(ValueSetElement) }
    rescue Exception => ex
      errors.add(:base, :parent_exception)
      nil
    end
  end

  def core_field_element
    core_field_element = self
    until core_field_element.is_a?(CoreFieldElement) do
      core_field_element = core_field_element.parent
    end
    return core_field_element
  end

  private

  def validate_question_short_name_uniqueness
    conditions = []
    conditions[0] = "form_id = ? and type = 'QuestionElement'"

    if (self.question_element_state == :new_question_on_form)
      parent_element = FormElement.find(parent_element_id)
      conditions << parent_element.form_id
    elsif (self.question_element_state == :edit_question_on_form)
      conditions << self.form_id
      conditions[0] << " and id != ?"
      conditions << self.id
    elsif (self.question_element_state == :copying_question_from_library)
      conditions << self.form_id
    end

    existing_question_elements = FormElement.find(:all, :conditions => conditions)

    if (existing_question_elements.detect { |element| element.question.short_name == self.question.short_name })
      self.errors.add(:base, :short_name_taken)
    end
  end

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
