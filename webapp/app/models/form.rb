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

require 'zip/zip'
require 'zip/zipfilesystem'

class Form < ActiveRecord::Base
  before_validation :replace_spaces_in_short_name

  has_and_belongs_to_many :diseases, :order => "disease_id"
  belongs_to :jurisdiction, :class_name => "PlaceEntity", :foreign_key => "jurisdiction_id"

  has_one :form_base_element, :class_name => "FormElement", :conditions => "parent_id is null"
  has_many :form_elements, :include => [:question]
  has_many :published_versions, :class_name => "Form", :foreign_key => "template_id", :order => "created_at DESC"
  belongs_to :template, :class_name => "Form"
  has_many :form_references
  has_many :questions, :finder_sql => %q{
    SELECT DISTINCT questions.*, form_elements.lft FROM form_elements
      JOIN questions ON form_elements.id = questions.form_element_id
     WHERE form_elements.form_id = #{id}
     ORDER BY form_elements.lft ASC
  }, :counter_sql => %q{
    SELECT COUNT(DISTINCT questions.id) FROM form_elements
      JOIN questions ON form_elements.id = questions.form_element_id
     WHERE form_elements.form_id = #{id}
  }

  validates_presence_of :name, :event_type
  validates_presence_of :short_name, :if => :is_template
  validates_each :short_name, :if => :is_template do |record, attr, value|
    conditions = ['short_name = ? AND is_template = ? AND status != ?', value, true, 'Inactive']
    if not record.new_record?
      conditions[0] += ' AND id != ?'
      conditions << record.id
    end
    if value && self.find(:first, :conditions => conditions)
      record.errors.add attr, :in_use
    end

    if record.short_name_changed?
      record.errors.add attr, :immutable if not record.short_name_editable?
    end
  end

  named_scope :templates, :conditions => {:is_template => true}, :order => 'name ASC'

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

  def exportable_questions
    form_element_cache.exportable_questions
  end

  def short_name_editable?
    return true if self.status == 'Not Published' || self.new_record?
    false
  end

  # Returns true if there's something interesting for the investigation tab to
  # render.
  def has_investigator_view_elements?
    investigator_view_elements_container.all_children.each_with_index do |c, i|
      return true if i > 0 || c.read_attribute(:type) != 'ViewElement'
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
        logger.error ex
        return nil
      end
    end
  end

  def event_type(*args)
    defaults = {:hide_dummy => false}
    options = args.extract_options!
    defaults.merge! options

    event_type = read_attribute(:event_type)
    if defaults[:hide_dummy] && event_type == "morbidity_and_assessment_event"
      return "morbidity_event"
    else
      return event_type
    end
  end

  def publish
    raise(I18n.translate('cannot_publish_already_published_version')) unless self.is_template

    published_form = nil;

    return if not valid?

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
            :short_name => self.short_name,
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

  def deactivate
    unless self.status == "Published"
      self.errors.add_to_base(:deactivate_unpublished)
      return nil
    end

    begin
      transaction do
        self.status = "Inactive"
        version_to_archive = most_recent_version
        version_to_archive.status = "Archived"
        self.save!
        version_to_archive.save!
        return true
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
        copied_form.name << " (#{I18n.t('copy')})"
        copied_form.short_name << "_#{I18n.t('copy')}"
        copied_form.ensure_short_name_unique
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

  def ensure_short_name_unique
    return if self.short_name.nil?
    count = Form.count(:conditions => ['short_name LIKE ?', "#{short_name}%"]).to_i
    self.short_name = self.short_name + count.to_s if count > 0
  end

  # Operates on a template for which there is at least one published
  # version, establishing a new template based on the most recent
  # published copy.
  #
  # Debt: There's some duplication of the publish method in here.
  def rollback

    unless self.status == "Published"
      self.errors.add_to_base(:rollback_unpublished)
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

  def push(event_type = self.event_type)
    if self.diseases.empty?
      self.errors.add_to_base(:no_diseases)
      return nil
    end

    begin
      most_recent_form = most_recent_version
      return nil if most_recent_form.nil?
      push_count = 0
      jurisdiction_ids = self.jurisdiction_id.nil? ? jurisdiction_ids = Place.jurisdictions.collect {|place| place.id } : jurisdiction_ids = self.jurisdiction_id
      conditions_array = []
      
      conditions_array[0] = "events.type = ? "
      conditions_array << event_type.camelcase

      conditions_array[0] << "AND participations.type = ? "
      conditions_array << "Jurisdiction"

      conditions_array[0] << " AND participations.secondary_entity_id IN (?) "
      conditions_array << jurisdiction_ids

      conditions_array[0] << " AND disease_events.disease_id IN (?)"
      conditions_array << self.disease_ids

      joins = "INNER JOIN participations ON participations.event_id = events.id "
      joins << "INNER JOIN disease_events ON disease_events.event_id = events.id"

      events = Event.find(:all,
        :conditions => conditions_array,
        :joins => joins
      )

      events.each do |event|
        form_template_ids = event.form_references.collect { |ref| ref.form.template_id }
        unless (form_template_ids.include?(self.id))
          event.form_references << FormReference.create(:event_id => event.id, :form_id => most_recent_form.id, :template_id => most_recent_form.template_id)
          push_count += 1
        end
      end

      push_count
    rescue Exception => ex
      logger.error ex
      self.errors.add_to_base(:publishing_error)
      return nil
    end

  end

  def export
    begin
      base_path = "/tmp/"
      zip_file_path = "#{base_path}#{form_name_as_file_name}.zip"

      form_file_name = "form"
      form_elements_file_name = "elements"

      File::open("#{base_path}#{form_file_name}", 'w') { |file| file << (self.to_json) }
      File::open("#{base_path}#{form_elements_file_name}", 'w') do |file|
        file << self.form_element_cache.full_set.to_json(:methods => [
            :type, :question, :code_condition_lookup, :cdc_export_column_lookup, :cdc_export_conversion_value_lookup
          ])
      end

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
      self.errors.add_to_base(ex.message)
      logger.error ex
      return nil
    end
  end

  def self.import(form_upload)
    begin
      imported_form = nil
      base_path = "/tmp/"
      uploaded_file_name = form_upload.original_filename
      File::open("#{base_path}#{uploaded_file_name}", 'w') { |file| file << form_upload.read }
      Zip::ZipFile.open("#{base_path}#{uploaded_file_name}") do |zip|
        imported_form = import_form(zip.read("form"), zip.read("elements"))
      end
      return imported_form
    rescue Exception => ex
      logger.error ex
      raise ex
    end
  end

  def self.export_library
    begin
      base_path = "/tmp/"
      zip_file_path = "#{base_path}#{I18n.translate('library_export_file_name')}.zip"
      form_elements_file_name = "library-elements"
      library_elements = []

      FormElement.library_roots.each do |library_root|
        library_root_json = FormElementCache.new(library_root).full_set.to_json(:methods => [
            :type, :question, :code_condition_lookup, :cdc_export_column_lookup, :cdc_export_conversion_value_lookup
          ])
        library_elements << library_root_json[1...library_root_json.size-1]
      end

      File::open("#{base_path}#{form_elements_file_name}", 'w') do |file|
        file << ("[" << library_elements.join(",") << "]")
      end

      File.delete(zip_file_path) if File.file?(zip_file_path)
      Zip::ZipFile.open(zip_file_path, Zip::ZipFile::CREATE) { |zip| zip.add( form_elements_file_name, "#{base_path}#{form_elements_file_name}") }
      File.delete("#{base_path}#{form_elements_file_name}")
      File.chmod(0644, zip_file_path)
      return zip_file_path
    rescue Exception => ex
      logger.error ex
      raise ex
    end
  end

  def self.import_library(form_upload)
    begin
      base_path = "/tmp/"
      uploaded_file_name = form_upload.original_filename
      File::open("#{base_path}#{uploaded_file_name}", 'w') { |file| file << form_upload.read }
      Zip::ZipFile.open("#{base_path}#{uploaded_file_name}") do |zip|

        begin
          zip_contents = zip.read("library-elements")
        rescue
          raise(I18n.translate('zip_file_missing_library_export'))
        end

        raise(I18n.translate('import_file_empty')) if zip_contents.blank?

        transaction do
          import_elements(zip_contents)
        end
      end
      return true
    rescue Exception => ex
      logger.error ex
      raise ex
    end
  end

  def most_recent_version(form_id = nil)
    form_id = form_id.nil? ? self.id : form_id
    Form.find(:first, :conditions => {:template_id => form_id, :is_template => false}, :order => "version DESC")
  end

  def self.get_published_investigation_forms(disease_id, jurisdiction_id, event_type)
    event_type = event_type.to_s
    if event_type == "assessment_event" || event_type == "morbidity_event"
      conditions = ["(event_type = ? OR event_type = ?) AND diseases_forms.disease_id = ? AND ( jurisdiction_id = ? OR jurisdiction_id IS NULL ) AND status = 'Live'",
        event_type, "morbidity_and_assessment_event", disease_id, jurisdiction_id ]
    else
      conditions = ["event_type = ? AND diseases_forms.disease_id = ? AND ( jurisdiction_id = ? OR jurisdiction_id IS NULL ) AND status = 'Live'",
        event_type, disease_id, jurisdiction_id ]
    end
    Form.find(:all,
      :include => :diseases,
      :conditions => conditions,
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
  #
  # Offloads non-form-specific validation to FormElement.structural_errors
  def structural_errors
    structural_errors = form_base_element.structural_errors

    structural_errors << :invalid_base_element unless form_base_element.class.name == "FormBaseElement"

    if form_base_element.children_count == 3
      structural_errors << :investigator_view_type unless form_base_element.children[0].class.name == "InvestigatorViewElementContainer"
      structural_errors << :core_view_type unless form_base_element.children[1].class.name == "CoreViewElementContainer"
      structural_errors << :core_field_type unless form_base_element.children[2].class.name == "CoreFieldElementContainer"
    else
      structural_errors << :incorrect_top_level
    end

    structural_errors
  end

  def question_count
    FormElement.find(:all, :conditions => ["form_id = ? and type = 'QuestionElement'", self.id]).size
  end

  def element_count
    FormElement.find(:all, :conditions => ["form_id = ?", self.id]).size
  end

  def cdc_question_count
    FormElement.find(:all, :conditions => ["form_id = ? and export_column_id is not null and type = 'QuestionElement'", self.id]).size
  end

  def core_element_count
    FormElement.find(:all, :conditions => ["form_id = ? and core_path is not null", self.id]).size
  end

  def elements_last_updated
    element = FormElement.find(:first, :conditions => ["form_id = ?", self.id], :order => "updated_at DESC")
    element.updated_at
  end

  def replace_spaces_in_short_name
    self.short_name = self.short_name.gsub(/ /, '_') if self.short_name
  end

  private

  def form_name_as_file_name
    name.strip.downcase.gsub(/ /, '_').gsub(/\\|\//, '-')
  end

  def initialize_form_elements
    begin
      tree_id = FormElement.next_tree_id
      form_base_element = FormBaseElement.create({:form_id => self.id, :tree_id => tree_id})

      investigator_view_element_container = InvestigatorViewElementContainer.create({:form_id => self.id, :tree_id => tree_id })
      core_view_element_container = CoreViewElementContainer.create({:form_id => self.id, :tree_id => tree_id })
      core_field_element_container = CoreFieldElementContainer.create({:form_id => self.id, :tree_id => tree_id })

      form_base_element.add_child(investigator_view_element_container)
      form_base_element.add_child(core_view_element_container)
      form_base_element.add_child(core_field_element_container)

      default_view_element = ViewElement.create({
          :form_id => self.id,
          :tree_id => tree_id,
          :name => I18n.translate('default_view')})
      investigator_view_element_container.add_child(default_view_element)
    rescue Exception => ex
      errors.add_to_base(:initialization_error)
      logger.error ex
      raise
    end
  end

  def self.copy_form_elements(from_form, to_form, include_inactive = true)
    elements = FormElementCache.new(from_form.form_base_element).full_set
    parent_id_map = {}
    tree_id = FormElement.next_tree_id
    inactive_element_ids = []

    elements.each do |e|
      values = {}
      values[:form_id] = to_form.id
      values[:type] = "'#{sanitize_sql(["%s", e.class.name])}'"
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
      values[:code] = null_safe_sanitize(e.code)

      result = insert_element(values)
      parent_id_map[e.id] = result
      inactive_element_ids << result if e.is_active == false
      copy_question(result, e) if (e.class.name == "QuestionElement")
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
        form.jurisdiction_id = nil
        form.status = "Not Published"
        form.save!
        import_elements(elements_import_string, form.id)
        raise("Structural error in imported form") unless form.structural_errors.empty?
        return form
      end
    rescue Exception => ex
      logger.error ex
      raise ex
    end
  end

  def self.import_elements(element_import_string, form_id = nil)
    elements = ActiveSupport::JSON.decode(element_import_string)
    raise(I18n.translate('import_file_empty')) if elements.empty?
    parent_id_map = {}
    tree_id = FormElement.next_tree_id unless form_id.nil?

    elements.each do |e|
      tree_id = FormElement.next_tree_id if (form_id.nil? && e["parent_id"].nil?)
      values = {}
      values[:form_id] = null_safe_sanitize(form_id)
      values[:type] = "'#{sanitize_sql(["%s", e["type"]]).untaint}'"
      values[:name] = null_safe_sanitize(e["name"])
      values[:description] = null_safe_sanitize(e["description"])
      values[:parent_id] = parent_id_map[e["parent_id"].to_i].nil? ? "null" : parent_id_map[e["parent_id"].to_i]
      values[:lft] = "'#{sanitize_sql(["%s", e["lft"]]).untaint}'"
      values[:rgt] = "'#{sanitize_sql(["%s",  e["rgt"]]).untaint}'"
      values[:is_active] = "#{sanitize_sql(["%s", e["is_active"]]).untaint}"
      values[:tree_id] = "#{sanitize_sql(["%s", tree_id]).untaint}"
      values[:core_path] = null_safe_sanitize(e["core_path"])
      values[:help_text] = null_safe_sanitize(e["help_text"])
      values[:is_condition_code] = null_safe_sanitize(e["is_condition_code"])
      values[:code] = null_safe_sanitize(e["code"])

      # Debt: Break these out into methods. They do the lookups for codes and export values to get the correct
      # IDs for the system receiving the form import.
      unless e["export_column_id"].nil?
        begin
          disease_group_name, export_column_name = e["cdc_export_column_lookup"].split(FormElement.export_lookup_separator)
          disease_group = ExportDiseaseGroup.find_by_name(disease_group_name)
          raise if disease_group.nil?
          export_column = ExportColumn.find_by_export_column_name_and_export_disease_group_id(export_column_name, disease_group.id)
          raise if export_column.nil?
          values[:export_column_id] = export_column.id
        rescue
          if (e["type"] == "QuestionElement")
            element_type = "question"
            identifier = e["question"]["question_text"]
          else
            element_type = "value set"
            identifier = e["name"]
          end

          raise(I18n.translate('unable_to_find_export_column_data',
              :disease_group_name => disease_group_name,
              :export_column_name => export_column_name,
              :element_type => element_type,
              :identifier => identifier))
        end
      else
        values[:export_column_id] =  null_safe_sanitize(e["export_column_id"])
      end

      unless e["export_conversion_value_id"].nil?
        begin
          disease_group_name, export_column_name, value_from, value_to = e["cdc_export_conversion_value_lookup"].split(FormElement.export_lookup_separator)
          value_from = value_from.blank? ? nil : value_from
          value_to = value_to.blank? ? nil : value_to
          disease_group = ExportDiseaseGroup.find_by_name(disease_group_name)
          raise if disease_group.nil?
          export_column = ExportColumn.find_by_export_column_name_and_export_disease_group_id(export_column_name, disease_group.id)
          raise if export_column.nil?
          export_conversion_value = ExportConversionValue.find_by_export_column_id_and_value_from_and_value_to(export_column.id, value_from, value_to)
          raise if export_conversion_value.nil?
          values[:export_conversion_value_id] = export_conversion_value.id
        rescue
          raise(I18n.translate('unable_to_find_export_conversion_value_date',
              :disease_group_name => disease_group_name,
              :export_column_name => export_column_name,
              :value_from => value_from,
              :value_to => value_to))
        end
      else
        values[:export_conversion_value_id] =  null_safe_sanitize(e["export_conversion_value_id"])
      end

      if e["is_condition_code"] == true
        begin
          code_name, the_code  = e["code_condition_lookup"].split(FormElement.export_lookup_separator)
          external_code = ExternalCode.find_by_code_name_and_the_code(code_name, the_code)
          raise if external_code.nil?
          values[:condition] = external_code.id
        rescue
           raise(I18n.translate('unable_to_find_system_code_fore_core_follow_up',
              :code_name => code_name,
              :the_code => the_code,
              :core_path => e["core_path"]))
        end
      else
        values[:condition] =  null_safe_sanitize(e["condition"])
      end

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
    sql << "export_conversion_value_id, code, created_at, updated_at) "
    sql << "VALUES (#{ values[:form_id]}, #{values[:type]} , #{values[:name]}, #{values[:description]}, "
    sql << "#{values[:parent_id]}, #{values[:lft]}, #{values[:rgt]}, false, null, #{values[:is_active]}, "
    sql << "#{values[:tree_id]}, #{ values[:condition]}, #{values[:core_path]}, #{values[:is_condition_code]}, "
    sql << "#{values[:help_text]}, #{values[:export_column_id]}, #{values[:export_conversion_value_id]}, #{values[:code]}, now(), now())"
    ActiveRecord::Base.connection.insert(sql)
  end

  # Debt? Rails' sanitize method wants to put null values in quotes.
  def self.null_safe_sanitize(value)
    value.blank? ? "null" :  "#{sanitize_sql_for_conditions(["'%s'", value]).untaint}"
  end

end
