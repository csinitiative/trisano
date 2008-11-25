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

require 'zip/zip'
require 'zip/zipfilesystem'

class Form < ActiveRecord::Base
  has_and_belongs_to_many :diseases, :order => "disease_id"
  belongs_to :jurisdiction, :class_name => "Entity", :foreign_key => "jurisdiction_id"
  
  has_one :form_base_element, :class_name => "FormElement", :conditions => "parent_id is null"
  has_many :form_elements, :include => [:question]
  
  validates_presence_of :name, :event_type
  
  def form_element_cache
    @form_element_cache ||=  FormElementCache.new(form_base_element)
  end
  
  def investigator_view_elements_container
    form_element_cache.children[0]
  end
  
  def core_view_elements_container
    form_element_cache.children[1]
  end
  
  def core_field_elements_container
    form_element_cache.children[2]
  end
  
  # Returns true if there's something interesting for the investigation tab to
  # render.
  def has_investigator_view_elements?
    investigator_view_elements_container.all_children.each_with_index do |c, i|
      return true if i > 0 || c.name != 'Default View'
    end
    false
  end

  # Saves the form and bootstraps its form element structure. Returns true on
  # success, false on failure. The ActiveRecord::Validations#errors array can be
  # checked for errors by clients.
  def save_and_initialize_form_elements
    if self.valid?
      begin
        transaction do
          self.status = 'Not Published'
          self.is_template = true
          self.save!
          initialize_form_elements
          raise unless structure_valid?
          return true
        end
      rescue Exception => ex
        return nil
      end
    end
  end
  
  def publish
    
    raise("Cannot publish an already published version") unless self.is_template
    
    published_form = nil;
    
    begin
      transaction do
      
        most_recent_form = most_recent_version
        new_version_number =(most_recent_form.nil? ? 0 : most_recent_form.version)+1
      
        unless most_recent_form.nil?
          most_recent_form.status = "Archived"
          most_recent_form.save
        end
        
        unless self.rolled_back_from_id.blank?
          most_recent_pre_rollback_form = most_recent_version(self.rolled_back_from_id)
          unless (most_recent_pre_rollback_form.status == "Archived")
            most_recent_pre_rollback_form.status = "Archived"
            most_recent_pre_rollback_form.save!
          end
        end
      
        published_form = Form.create({:name => self.name, 
            :event_type => self.event_type, 
            :description => self.description, 
            :jurisdiction => self.jurisdiction, 
            :version => new_version_number, 
            :status => 'Live',
            :is_template => false,
            :template_id => self.id 
          })
       
        Form.copy_form_elements(self, published_form, false)
              
        unless self.status == 'Published'
          self.status = 'Published'
          self.save
        end

        # Associate newly published form with the same diseases as current form
        self.diseases.each { | disease | published_form.diseases << disease }
        
        # Note: Errors in the published form's structure are added to the form that's being published
        published_form_structural_errors = published_form.structural_errors
        unless published_form_structural_errors.empty?
          published_form_structural_errors.each do |error|
            errors.add_to_base(error)
          end
          raise
        end
        
        return published_form
      end
    rescue Exception => ex
      logger.error ex
      return nil
    end
    
  end

  def copy
    copied_form = nil
    begin
      transaction do
        copied_form = self.clone
        copied_form.name << " (Copy)"
        copied_form.created_at = nil
        copied_form.updated_at = nil
        copied_form.status = 'Not Published'
        copied_form.is_template = true
        copied_form.save!
        self.diseases.each do |disease|
          copied_form.diseases << disease
        end
        Form.copy_form_elements(self, copied_form)
      end

      return copied_form

    rescue Exception => ex
      logger.error ex
      return nil
    end    
  end
  
  # Operates on a template for which there is at least one published
  # version, establishing a new template based on the most recent
  # published copy.
  #
  # Debt: There's some duplication of the publish method in here.
  def rollback
    
    unless self.status == "Published"
      self.errors.add_to_base("Only forms with published versions can be rolled back")
      return nil
    end
    
    begin
      transaction do
        most_recent_form = most_recent_version

        rolled_back_form = self.clone
        rolled_back_form.created_at = nil
        rolled_back_form.status = "Published"
        rolled_back_form.rolled_back_from_id = self.id
        self.status = "Invalid"
        self.is_template = false
      
        self.save!
        rolled_back_form.save!
        
        Form.copy_form_elements(most_recent_form, rolled_back_form)
        
        # Associate newly copied form with the same diseases as current form
        self.diseases.each { | disease | rolled_back_form.diseases << disease }
        
        # Note: Errors in the rolled back form's structure are added to the form that's being rolled back
        rolled_back_form_structural_errors = rolled_back_form.structural_errors
        unless rolled_back_form_structural_errors.empty?
          rolled_back_form_structural_errors.each do |error|
            errors.add_to_base(error)
          end
          raise
        end
        
        return rolled_back_form
      end
      
    rescue Exception => ex
      logger.error ex
      return nil
    end
    
  end

  def push
    if self.diseases.empty?
      self.errors.add_to_base("There are no diseases associated with this form.")
      return nil
    end

    begin
      most_recent_form = most_recent_version
      return nil if most_recent_form.nil?
      push_count = 0
      jurisdiction_ids = self.jurisdiction_id.nil? ? jurisdiction_ids = Place.jurisdictions.collect {|place| place.id }.join(", ") : jurisdiction_ids = self.jurisdiction_id
    
      conditions = "events.type = '#{self.event_type.camelcase}'"
      conditions << "AND participations.role_id = #{Event.primary_jurisdiction_code_id} "
      conditions << "AND participations.secondary_entity_id IN (#{jurisdiction_ids}) "
      conditions << "AND disease_events.disease_id IN (#{self.disease_ids.join(", ")})"
    
      joins = "INNER JOIN participations ON participations.event_id = events.id "
      joins << "INNER JOIN disease_events ON disease_events.event_id = events.id"
    
      events = Event.find(:all,
        :conditions => conditions,
        :joins => joins
      )

      events.each do |event|
        form_template_ids = event.form_references.collect { |ref| ref.form.template_id }
        unless (form_template_ids.include?(self.id))
          event.form_references << FormReference.create(:event_id => event.id, :form_id => most_recent_form.id)
          push_count += 1
        end
      end
    
      push_count
    rescue Exception => ex
      logger.error ex
      self.errors.add_to_base("There an error occurred while pushing the form.")
      return nil
    end

  end

  def export
    begin
      base_path = "/tmp/"
      form_name = self.name.downcase.sub(" ", "_")
      zip_file_path = "#{base_path}#{form_name}.zip"
    
      form_file_name = "form"
      form_elements_file_name = "elements"
    
      open("#{base_path}#{form_file_name}", 'w') { |file| file << (self.to_json) }
      open("#{base_path}#{form_elements_file_name}", 'w') { |file|  file << self.form_element_cache.full_set.patched_array_to_json(:methods => [:type, :question]) }

      File.delete(zip_file_path) if File.file?(zip_file_path)

      Zip::ZipFile.open(zip_file_path, Zip::ZipFile::CREATE) do |zip|
        zip.add( form_file_name, "#{base_path}#{form_file_name}")
        zip.add( form_elements_file_name, "#{base_path}#{form_elements_file_name}")
      end
    
      File.delete("#{base_path}#{form_file_name}")
      File.delete("#{base_path}#{form_elements_file_name}")
    
      File.chmod(0644, zip_file_path)
      return zip_file_path
    rescue Exception => ex
      logger.error ex
      return nil
    end
  end
  
  def self.import(form_upload)
    base_path = "/tmp/"
    uploaded_file_name = form_upload.original_filename
    open("#{base_path}#{uploaded_file_name}", 'w') { |file| file << form_upload.read }

    Zip::ZipFile.open("#{base_path}#{uploaded_file_name}") do |zip|
      import_form(zip.read("form"), zip.read("elements"))
    end
  end

  def most_recent_version(form_id = nil)
    form_id = form_id.nil? ? self.id : form_id
    Form.find(:first, :conditions => {:template_id => form_id, :is_template => false}, :order => "version DESC")
  end
  
  def self.get_published_investigation_forms(disease_id, jurisdiction_id, event_type)
    event_type = event_type.to_s
    Form.find(:all,
      :include => :diseases,
      :conditions => ["event_type = ? and diseases_forms.disease_id = ?  AND ( jurisdiction_id = ? OR jurisdiction_id IS NULL ) AND status = 'Live'",
        event_type, disease_id, jurisdiction_id ],
      :order => "forms.created_at ASC"
    )
  end
  
  # Calls checks the form element structure and adds errors to the
  # ActiveRecord::Validations#errors array of form that is self at the
  # time of calling.
  def structure_valid?
    structural_error_collection = structural_errors
    if structural_error_collection.empty?
      return true
    else
      structural_error_collection.each do |error|
        errors.add_to_base(error)
      end
      return false
    end
  end
  
  # Builds an array of structural error messages. Returns an empty array if all
  #  is well.  Does not go against the cache and does not utilize the
  #  ActiveRecord::Validations#errors array.
  def structural_errors
    structural_errors = []
    structural_errors << "Form base element is invalid" unless form_base_element.attributes["type"] == "FormBaseElement"
    structural_errors << "Nesting structure is corrupt" if FormElement.find_by_sql("select id, type, name, lft, rgt from form_elements where form_id = #{self.id} and lft > rgt;").size > 0
    
    if form_base_element.children_count == 3
      structural_errors << "Investigator view element container is the wrong type" unless form_base_element.children[0].attributes["type"] == "InvestigatorViewElementContainer"
      structural_errors << "Core view element container is the wrong type" unless form_base_element.children[1].attributes["type"] == "CoreViewElementContainer"
      structural_errors << "Core field element container is the wrong type" unless form_base_element.children[2].attributes["type"] == "CoreFieldElementContainer"
    else
      structural_errors << "Form does not contain the correct top-level containers"
    end

    structural_errors
  end
  
  
  private
  
  def initialize_form_elements
    begin
      tree_id = Form.next_tree_id
      form_base_element = FormBaseElement.create({:form_id => self.id, :tree_id => tree_id})
    
      investigator_view_element_container = InvestigatorViewElementContainer.create({:form_id => self.id, :tree_id => tree_id })
      core_view_element_container = CoreViewElementContainer.create({:form_id => self.id, :tree_id => tree_id })
      core_field_element_container = CoreFieldElementContainer.create({:form_id => self.id, :tree_id => tree_id })
    
      form_base_element.add_child(investigator_view_element_container)
      form_base_element.add_child(core_view_element_container)
      form_base_element.add_child(core_field_element_container)
    
      default_view_element = ViewElement.create({:form_id => self.id, :tree_id => tree_id, :name => "Default View"})
      investigator_view_element_container.add_child(default_view_element)
    rescue Exception => ex
      errors.add_to_base("An error occurred initializing form elements")
      logger.error ex
      raise
    end
  end

  def self.next_tree_id
    Form.find_by_sql("SELECT nextval('tree_id_generator')").first.nextval.to_i
  end
  
  def self.copy_form_elements(from_form, to_form, include_inactive = true)
    elements = from_form.form_element_cache.full_set
    parent_id_map = {}
    tree_id = Form.next_tree_id
    inactive_element_ids = []
    
    elements.each do |e|
      values = {}
      values[:form_id] = to_form.id
      values[:type] = "'#{sanitize_sql(["%s", e.attributes["type"]])}'"
      values[:name] = null_safe_sanitize(e.name)
      values[:description] = null_safe_sanitize(e.description)
      values[:parent_id] = null_safe_sanitize(parent_id_map[e.parent_id])
      values[:lft] = "'#{sanitize_sql(["%s", e.lft])}'"
      values[:rgt] = "'#{sanitize_sql(["%s", e.rgt])}'"
      values[:is_active] = "#{sanitize_sql(["%s", e.is_active])}"
      values[:tree_id] = "#{sanitize_sql(["%s", tree_id])}"
      values[:condition] =  null_safe_sanitize(e.condition)
      values[:core_path] = null_safe_sanitize(e.core_path)
      values[:is_condition_code] = null_safe_sanitize(e.is_condition_code)
      values[:help_text] = null_safe_sanitize(e.help_text)
      values[:export_column_id] = null_safe_sanitize(e.export_column_id)
      values[:export_conversion_value_id] = null_safe_sanitize(e.export_conversion_value_id)

      result = insert_element(values)
      parent_id_map[e.id] = result
      inactive_element_ids << result if e.is_active == false
      copy_question(result, e) if (e.attributes["type"] == "QuestionElement")
    end
    
    unless (include_inactive)
      inactive_element_ids.each do |id|
        begin
          inactive_element = FormElement.find(id)
          inactive_element.destroy
        rescue
          # No-op, the element has already been deleted
        end
        
      end
    end
    
  end
  
  def self.copy_question(published_question_element_id, template_question_element)
    template_question = template_question_element.question
    
    question_to_publish = Question.new({:form_element_id => published_question_element_id,
        :question_text => template_question.question_text,
        :short_name => template_question.short_name,
        :help_text => template_question.help_text,
        :data_type => template_question.data_type_before_type_cast,
        :core_data => template_question.core_data,
        :core_data_attr => template_question.core_data_attr,
        :size => template_question.size,
        :is_required => template_question.is_required,
        :style => template_question.style
      })
   
    question_to_publish.save
  end
  
  def self.import_form(form_import_string, elements_import_string)
    begin
      transaction do
        form = Form.new(ActiveSupport::JSON.decode(form_import_string))
        form.rolled_back_from_id = nil
        form.template_id = nil
        form.status = "Not Published"
        form.save!
        import_elements(elements_import_string, form.id)
        raise("Structural error in imported form") unless form.structural_errors.empty?
        return form
      end
    rescue Exception => ex
      logger.error ex
      return nil
    end
  end

  def self.import_elements(element_import_string, form_id)
    elements = ActiveSupport::JSON.decode(element_import_string)
    parent_id_map = {}
    tree_id = Form.next_tree_id
      
    elements.each do |e|
      values = {}
      values[:form_id] = form_id
      values[:type] = "'#{sanitize_sql(["%s", e["type"]])}'"
      values[:name] = null_safe_sanitize(e["name"])
      values[:description] = null_safe_sanitize(e["description"])
      values[:parent_id] = parent_id_map[e["parent_id"].to_i].nil? ? "null" : parent_id_map[e["parent_id"].to_i]
      values[:lft] = "'#{sanitize_sql(["%s", e["lft"]])}'"
      values[:rgt] = "'#{sanitize_sql(["%s",  e["rgt"]])}'"
      values[:is_active] = "#{sanitize_sql(["%s", e["is_active"]])}"
      values[:tree_id] = "#{sanitize_sql(["%s", tree_id])}"
      values[:condition] =  null_safe_sanitize(e["condition"])
      values[:core_path] = null_safe_sanitize(e["core_path"])
      values[:is_condition_code] = null_safe_sanitize(e["is_condition_code"])
      values[:help_text] = null_safe_sanitize(e["help_text"])
      values[:export_column_id] = null_safe_sanitize(e["export_column_id"])
      values[:export_conversion_value_id] = null_safe_sanitize(e["export_conversion_value_id"])

      result = insert_element(values)
      parent_id_map[e["id"]] = result
      import_question(e["question"], result)  if (e["type"] == "QuestionElement")
    end
  end
  
  def self.import_question(question_import_string, form_element_id)
    question = Question.new(question_import_string)
    question.form_element_id = form_element_id
    question.save!
  end

  # Inserts an element into form_elements, bypassing nested-set processing. Assumes
  # values have been sanitized.
  def self.insert_element(values)
    sql = "INSERT INTO form_elements "
    sql << "(form_id, type, name, description, parent_id, lft, rgt, is_template, template_id, "
    sql << "is_active, tree_id, condition, core_path, is_condition_code, help_text, export_column_id, "
    sql << "export_conversion_value_id, created_at, updated_at) "
    sql << "VALUES (#{ values[:form_id]}, #{values[:type]} , #{values[:name]}, #{values[:description]}, "
    sql << "#{values[:parent_id]}, #{values[:lft]}, #{values[:rgt]}, false, null, #{values[:is_active]}, "
    sql << "#{values[:tree_id]}, #{ values[:condition]}, #{values[:core_path]}, #{values[:is_condition_code]}, "
    sql << "#{values[:help_text]}, #{values[:export_column_id]}, #{values[:export_conversion_value_id]}, now(), now());"
    ActiveRecord::Base.connection.insert(sql)
  end

  # Debt? Rails' sanitize method wants to put null values in quotes.
  def self.null_safe_sanitize(value)
    value.blank? ? "null" :  "'#{sanitize_sql(["%s", value])}'"
  end
  
end
