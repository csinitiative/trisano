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

class FormElement < ActiveRecord::Base
  include Export::Cdc::FormElementExt

  acts_as_nested_set :scope => :tree_id
  belongs_to :form
  has_one :question
  belongs_to :export_column

  named_scope :library_roots, :conditions => {
    :parent_id => nil,
    :form_id => nil
    }

  @@export_lookup_separator = "|||"
  
  # Generic save_and_add_to_form. Sub-classes with special needs override. Block can be used to add other
  # post-saving activities in the transaction
  def save_and_add_to_form
    if self.valid?
      begin
        transaction do
          parent_element = FormElement.find(parent_element_id)
          self.tree_id = parent_element.tree_id
          self.form_id = parent_element.form_id
          self.save
          yield if block_given?
          parent_element.add_child(self)
          validate_form_structure
          return true
        end
      rescue Exception => ex
        return nil
      end
    end
  end
  
  def update_and_validate(attributes)
    begin
      transaction do
        self.update_attributes(attributes)
        self.validate_form_structure
        return true
      end
    rescue
      return nil
    end
  end
  
  def destroy_and_validate
    begin
      transaction do
        self.destroy
        form.nil? ? validate_tree_structure : validate_form_structure
        return true
      end
    rescue
      return nil
    end
  end
  
  def reorder_element_children(ids)
    begin
      transaction do
        self.reorder_children(ids)
        validate_form_structure
        return true
      end
    rescue
      return nil
    end
    
  end
  
  def children_count_by_type(type_name)
    FormElement.calculate(:count, :type, :conditions => ["parent_id = ? and tree_id = ? and type = ?", self.id, self.tree_id, type_name])
  end
  
  def children_by_type(type_name)
    FormElement.find(:all, :conditions =>["parent_id = ? and tree_id = ? and type = ?", self.id, self.tree_id, type_name], :order => :lft)
  end
  
  # DEBT! Should make publish and add_to_library the same code
  def add_to_library(group_element=nil)
    begin
      transaction do
        if group_element.nil?
          tree_id = FormElement.find_by_sql("SELECT nextval('tree_id_generator')").first.nextval.to_i
          result = copy_children(self, nil, nil, tree_id, true)
        else
          tree_id = group_element.tree_id
          result = copy_children(self, group_element, nil, tree_id, true)
        end
        result.validate_tree_structure(self)
        return result
      end
    rescue
      return nil
    end
  end

  def copy_from_library(lib_element_id)
    begin
      transaction do
        library_element = FormElement.find(lib_element_id)
        if (library_element.class.name == "ValueSetElement" && !can_receive_value_set?)
          errors.add_to_base("Can't complete copy. A question can only have one value set")
          raise
        end
        self.add_child(copy_children(library_element, nil, self.form_id, self.tree_id, false))
        validate_form_structure
        return true
      end
    rescue Exception => ex
      return nil
    end
    
  end

  # Returns root node of the copied tree
  def copy_children(node_to_copy, parent, form_id, tree_id, is_template)
    e = node_to_copy.class.new
    e.form_id = form_id
    e.tree_id = tree_id
    e.is_template = is_template
    e.name = node_to_copy.name
    e.description = node_to_copy.description
    e.help_text = node_to_copy.help_text
    e.condition = node_to_copy.condition
    e.core_path = node_to_copy.core_path
    e.is_active = node_to_copy.is_active
    e.is_condition_code = node_to_copy.is_condition_code
    e.export_column_id = node_to_copy.export_column_id
    e.export_conversion_value_id = node_to_copy.export_conversion_value_id
    e.question = node_to_copy.question.clone if node_to_copy.is_a? QuestionElement
    e.save!
    parent.add_child e unless parent.nil?
    node_to_copy.children.each do |child|
      # Do not copy value sets in a group to non-questions
      unless (child.is_a?(ValueSetElement) && child.parent.is_a?(GroupElement) && !self.is_a?(QuestionElement))
        copy_children(child, e, form_id, tree_id, is_template)
      end      
    end
    e
  end

  def self.filter_library(options)
    if options[:filter_by].blank?
      FormElement.roots(:conditions => ["form_id IS NULL"])
    else
      if options[:direction].to_sym == :to_library
        FormElement.find_by_sql(["SELECT * FROM form_elements WHERE form_id IS NULL AND type = 'GroupElement' and name ILIKE ?", "%#{options[:filter_by]}%"])
      else
        raise Exception.new("No type specified for a from library filter") if options[:type].blank?
        if (options[:type] == :question_element)
          FormElement.find(:all, 
            :conditions => ["form_id IS NULL AND type = ? AND form_elements.id IN (SELECT form_element_id FROM questions WHERE question_text ILIKE ?)", options[:type].to_s.camelcase, "%#{options[:filter_by]}%"],
            :include => [:question]
          )
        else
          FormElement.find_by_sql(["SELECT * FROM form_elements WHERE form_id IS NULL AND type = ? AND name ILIKE ?", options[:type].to_s.camelcase, "%#{options[:filter_by]}%"])
        end
      end
    end
  end
  
  def validate_form_structure
    return if form.nil?
    structural_errors = form.structural_errors
    unless structural_errors.empty?
      structural_errors.each do |error|
        errors.add_to_base(error)
      end
      raise
    end
  end
  
  def validate_tree_structure(element_for_errors=nil)
    structural_errors = self.structural_errors
    unless structural_errors.empty?
      if (element_for_errors)
        structural_errors.each do |error|
          element_for_errors.errors.add_to_base(error)
        end
      end
      raise
    end
  end

  # Contains generic nested set validation checks for the tree that this node is in.
  #
  # Form#structural_errors contains additional checks specific to a form tree.
  def structural_errors    
    structural_errors = []

    structural_errors << "Multiple root elements were detected" if FormElement.find_by_sql("select id from form_elements where tree_id = #{self.tree_id} and parent_id is null").size > 1

    structural_errors << "Overlap was detected in the form element structure" if FormElement.find_by_sql("
      select result, count(*) from (SELECT lft as result FROM form_elements where tree_id = #{self.tree_id}
      UNION ALL SELECT rgt FROM form_elements where tree_id = #{self.tree_id} order by result) as elements
      group by result
      having count(*) > 1;"
    ).size > 0

    structural_errors << "Gaps were detected in the form element structure" if FormElement.find_by_sql("
      select l.result + 1 as start
      from (SELECT lft as result FROM form_elements where tree_id = #{self.tree_id}
      UNION SELECT rgt FROM form_elements where tree_id = #{self.tree_id} order by result) as l
      left outer join (SELECT lft as result FROM form_elements where tree_id = #{self.tree_id}
      UNION SELECT rgt FROM form_elements where tree_id = #{self.tree_id} order by result) as r on l.result + 1 = r.result
      where r.result is null;"
    ).size > 1
    
    structural_errors << "Orphaned elements were detected" if FormElement.find_by_sql("
      select id from form_elements where tree_id = #{self.tree_id} and parent_id not in (select id from form_elements where tree_id = #{self.tree_id});"
    ).size > 0
    
    structural_errors << "Nesting structure is corrupt" if FormElement.find_by_sql("select id, type, name, lft, rgt from form_elements where tree_id = #{self.tree_id} and lft >= rgt;").size > 0
    structural_errors
  end
  
  def can_receive_value_set?
    begin
      if (self.class.name == "QuestionElement")
        future_siblings = self.children
        existing_value_set = future_siblings.detect {|sibling| sibling.class.name == "ValueSetElement"}
        return false unless (existing_value_set.nil?)
      end
    rescue Exception => ex
      self.errors.add_to_base("An error occurred checking the parent for existing value set children")
      return nil
    end
    return true
  end
  
  def code_condition_lookup
    if self.is_condition_code
      begin
        external_code = ExternalCode.find(self.condition)
        return "#{external_code.code_name}#{@@export_lookup_separator}#{external_code.the_code}"
      rescue Exception => ex
        logger.error ex
        raise "The external code for the condition on #{self.core_path} could not be found."
      end
    end
  end
  
  def cdc_export_column_lookup
    if self.export_column_id
      begin
        export_column = ExportColumn.find(self.export_column_id, :include => :export_disease_group)
        return "#{export_column.export_disease_group.name}#{@@export_lookup_separator}#{export_column.export_column_name}"
      rescue Exception => ex 
        if self.class.name == "QuestionElement"
          element_type = "question"
          identifier = self.question.question_text
        else
          element_type = "value set"
          identifier = self.name
        end
        logger.error ex
        raise "The export column and/or disease group for the #{element_type} '#{identifier}' could not be found."
      end
    end
  end
  
  def cdc_export_conversion_value_lookup
    if self.export_conversion_value_id
      begin
        export_conversion_value = ExportConversionValue.find(self.export_conversion_value_id)
        export_column = ExportColumn.find(export_conversion_value.export_column_id, :include => :export_disease_group)
        return "#{export_column.export_disease_group.name}#{@@export_lookup_separator}#{export_column.export_column_name}#{@@export_lookup_separator}#{export_conversion_value.value_from}#{@@export_lookup_separator}#{export_conversion_value.value_to}"
      rescue Exception => ex
        logger.error ex
        raise "The conversion value, export column, or disease group could not be found for the value element '#{self.name}.'"
      end
    end
  end

  def self.export_lookup_separator
    @@export_lookup_separator
  end

  # Deletes answers to questions under a follow up. Used to clear out answers
  # to a follow up that no longer applies because its condition no longer matches
  # the answer provided by the user.
  def self.delete_answers_to_follow_ups(event_id, follow_up)
    return unless follow_up.is_a?(FollowUpElement)
    unless (event_id.blank?)
      question_elements_to_delete = QuestionElement.find(:all, :include => :question,
        :conditions => ["lft > ? and rgt < ? and tree_id = ?", follow_up.lft, follow_up.rgt, follow_up.tree_id])

      question_elements_to_delete.each do |question_element|
        answer = Answer.find_by_event_id_and_question_id(event_id, question_element.question.id)
        answer.destroy unless answer.nil?
      end
    end
  end

end
