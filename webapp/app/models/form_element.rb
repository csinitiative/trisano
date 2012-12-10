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

class FormElement < ActiveRecord::Base
  include Trisano::CorePathCallable

  before_destroy :delete_questions

  acts_as_nested_set :scope => :tree_id
  belongs_to :form
  belongs_to :export_column

  # sucks, but here so we can load the entire form tree as objects in one go
  has_one :question, :foreign_key => "form_element_id", :dependent => :destroy

  named_scope :library_roots, :conditions => {
    :parent_id => nil,
    :form_id => nil
  }

  attr_accessor :parent_element_id

  @@export_lookup_separator = "|||"

  class InvalidFormStructure < ActiveRecord::ActiveRecordError; end
  class IllegalCopyOperation < ActiveRecord::ActiveRecordError; end

  # Generic save_and_add_to_form. Sub-classes with special needs override. Block can be used to add other
  # post-saving activities in the transaction
  def save_and_add_to_form
    if self.valid?
      begin
        transaction do
          parent_element = FormElement.find(parent_element_id)
          self.tree_id = parent_element.tree_id
          self.form_id = parent_element.form_id
          self.save(false)
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
        if self.update_attributes(attributes)
          self.validate_form_structure
          return true
        else
          return nil
        end
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
        options = { :parent => group_element, :is_template => true }
        options[:tree_id] = group_element ? group_element.tree_id : FormElement.next_tree_id
        result = copy_with_children(options)
        result.validate_tree_structure(self)
        return result
      end
    rescue
      return nil
    end
  end

  def copy_from_library(library_element, options = {})
    begin
      transaction do
        if (library_element.class.name == "ValueSetElement" && !can_receive_value_set?)
          errors.add(:base, :failed_copy)
          raise IllegalCopyOperation
        end
        options = {
          :form_id => form_id,
          :tree_id => tree_id,
          :is_template => false }.merge(options)
        add_child(library_element.copy_with_children(options))
        validate_form_structure
        return true
      end
    rescue Exception => ex
      self.errors.add(:base, ex.message)
      raise
    end
  end

  # use this instead of cloning to spawn new nodes from old nodes
  # The contract works like this:
  #
  # 1. Everything is cool, return the copied element
  # 2. Not copiable. Return nil. Nothing copied, move along.
  # 3. Something went terribly wrong. Raise exception.
  #
  def copy(options = {})
    options.symbolize_keys!
    returning self.class.new do |e|
      hash = {
        'form_id' => options[:form_id],
        'tree_id' => options[:tree_id],
        'is_template' => options[:is_template],
        'lft' => nil,
        'rgt' => nil,
        'parent_id' => nil
      }
      e.attributes = attributes.merge(hash)
    end
  end

  # Returns root node of the copied tree
  def copy_with_children(options = {})
    options.symbolize_keys!
    if options[:parent] and options[:parent].tree_id != options[:tree_id]
      raise("tree_id must match the parent element's tree_id, if parent element is not nil")
    end
    if e = copy(options)
      e.save!
      options[:parent].add_child(e) if options[:parent]
      copy_children(options.merge(:parent => e))
      e
    end
  end

  def copy_children(options)
    children.each do |child|
      child.copy_with_children(options)
    end
  end

  # most form elements don't have a short name, so don't bother w/ db
  # stoofs
  def compare_short_names(other_tree_element, options={})
    []
  end

  def self.filter_library(options)
    if options[:filter_by].blank?
      FormElement.roots(:conditions => ["form_id IS NULL"])
    else
      if options[:direction].to_sym == :to_library
        FormElement.find_by_sql(["SELECT * FROM form_elements WHERE form_id IS NULL AND type = 'GroupElement' and name ILIKE ? ", "%#{options[:filter_by]}%"])
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
        errors.add(:base, error)
      end
      raise InvalidFormStructure, errors.full_messages.join("\n")
    end
  end

  def validate_tree_structure(element_for_errors=nil)
    structural_errors = self.structural_errors
    unless structural_errors.empty?
      if (element_for_errors)
        structural_errors.each do |error|
          element_for_errors.errors.add(:base, error)
        end
      end
      raise structural_errors.inspect
    end
  end

  # Contains generic nested set validation checks for the tree that this node is in.
  #
  # Form#structural_errors contains additional checks specific to a form tree.
  def structural_errors
    structural_errors = []

    structural_errors << :multiple_roots if FormElement.find_by_sql("select id from form_elements where tree_id = #{self.tree_id} and parent_id is null").size > 1

    structural_errors << :overlap if FormElement.find_by_sql("
      select result, count(*) from (SELECT lft as result FROM form_elements where tree_id = #{self.tree_id}
      UNION ALL SELECT rgt FROM form_elements where tree_id = #{self.tree_id} order by result) as elements
      group by result
      having count(*) > 1;"
    ).size > 0

    structural_errors << :structure_gaps if FormElement.find_by_sql("
      select l.result + 1 as start
      from (SELECT lft as result FROM form_elements where tree_id = #{self.tree_id}
      UNION SELECT rgt FROM form_elements where tree_id = #{self.tree_id} order by result) as l
      left outer join (SELECT lft as result FROM form_elements where tree_id = #{self.tree_id}
      UNION SELECT rgt FROM form_elements where tree_id = #{self.tree_id} order by result) as r on l.result + 1 = r.result
      where r.result is null;"
    ).size > 1

    structural_errors << :orphans if FormElement.find_by_sql("
      select id from form_elements where tree_id = #{self.tree_id} and parent_id not in (select id from form_elements where tree_id = #{self.tree_id});"
    ).size > 0

    structural_errors << :corrupt_nesting if FormElement.find_by_sql("select id, type, name, lft, rgt from form_elements where tree_id = #{self.tree_id} and lft >= rgt;").size > 0
    structural_errors
  end

  def can_receive_value_set?
    return false
  end

  def code_condition_lookup
    if self.is_condition_code
      begin
        external_code = ExternalCode.find(self.condition)
        return "#{external_code.code_name}#{@@export_lookup_separator}#{external_code.the_code}"
      rescue Exception => ex
        logger.error ex
        raise(I18n.translate('form_element_could_not_find_external_code', :core_path => self.core_path))
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
        raise(I18n.translate('form_element_export_column_or_disease_group_not_found', :element_type => element_type, :identifier => identifier))
      end
    end
  end

  def cdc_export_conversion_value_lookup
    if self.export_conversion_value_id
      begin
        export_conversion_value = ExportConversionValue.find(self.export_conversion_value_id)
        export_column = ExportColumn.find(export_conversion_value.export_column_id, :include => :export_disease_group)
        return "#{export_column.export_disease_group.name}#{@@export_lookup_separator}#{export_column.export_column_name}#{@@export_lookup_separator}#{export_conversion_value.value_from}#{@@export_lookup_separator}#{export_conversion_value.value_to}"
      rescue
        message = I18n.translate('form_element_something_not_found_for_value_element', :name => self.name)

        if self.form_id.blank?
          message << " #{I18n.translate('form_element_library_element_at_fault', :name => self.root.class.human_name)} "
          if self.root.class.name == "QuestionElement"
            message << "'#{self.root.question.question_text}'."
          else
            message << "'#{self.root.name}'."
          end
        end

        raise message
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

  def self.next_tree_id
    FormElement.find_by_sql("SELECT nextval('tree_id_generator')").first.nextval.to_i
  end

  def repeater?
    core_field.repeater? 
  end

  def core_field
    CoreField.find_by_key(core_field_element.core_path)
  end

  def core_path(event_type=nil)
    core_path ||= read_attribute(:core_path)
    if event_type
      core_path.sub(/^(.+)_event\[/, event_type)      
    else
      core_path
    end
  end

  def core_field_element
    if self.is_a?(CoreFieldElement)
      return self
    elsif self.parent and self.parent.respond_to?(:core_field_element)
      return self.parent.core_field_element
    else
      return nil
    end
  end
  protected

  # A little hack to make sure that questions get deleted when a
  # question element is deleted as part of a larger pruning operation.
  #
  # By default, acts_as_nested prunes children using delete_all. It
  # can be configured to use destroy, but that has two problems
  # 1) It's slow, 2) It's broken (it leaves gaps in the set).
  def delete_questions
    questions = self.children.collect {|child| child.id if child.is_a? QuestionElement}
    Question.delete_all ['form_element_id IN (?)', questions]
  end


end
