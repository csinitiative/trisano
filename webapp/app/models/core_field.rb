# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

class CoreField < ActiveRecord::Base
  include I18nCoreField

  acts_as_nested_set :scope => :tree_id if table_exists?

  belongs_to :code_name
  has_many :core_fields_diseases, :dependent => :destroy
  has_many :diseases, :through => :core_fields_diseases

  validates_presence_of :field_type
  validates_presence_of :event_type

  before_validation :normalize_attributes

  class << self

    def find_event_fields_for(event_type, *args)
      return [] if event_type.blank?
      with_scope(:find => {
          :conditions => ["event_type=?", event_type],
          :include => :core_fields_diseases
        }) do
        find(*args)
      end
    end

    # uses the memoization cache
    def event_fields(event_or_type)
      event_type = (event_or_type.is_a?(Event) ? event_or_type.type : event_or_type.to_s).underscore
      event_fields_hash[event_type] ||= find_event_fields_for(event_type, :all).inject({}) do |hash, field|
        hash[field.key] = field
        hash
      end
    end

    def flush_memoization_cache
      @event_fields_hash = nil
    end

    def next_tree_id
      self.find_by_sql("SELECT nextval('core_field_tree_id_generator')").first.nextval.to_i
    end

    def load!(hashes)
      transaction do
        hashes.each do |attrs|
          attrs.stringify_keys!
          unless self.find_by_key(attrs['key'])
            if (code_name = attrs.delete('code_name'))
              attrs['code_name'] = CodeName.find_by_code_name(code_name)
            end
            if section_key = attrs.delete('section_key')
              section = CoreField.find_by_key(section_key)
              logger.fatal "Couldn't find section: '#{section_key}'"
              attrs['tree_id'] = section.tree_id
            end
            if attrs['field_type'] == 'section'
              attrs['tree_id'] ||= CoreField.next_tree_id
            end
            core_field = CoreField.create!(attrs)
            if section
              section.add_child core_field
            end
          end
        end
      end
    end

    # keep virtual attribute :rendered_attributes from being part of
    # error messages
    def human_attribute_name(attribute)
      return "" if attribute.to_sym == :rendered_attributes
      super
    end


    private

    def event_fields_hash
      @event_fields_hash ||= {}
    end
  end

  def validate
    super
    if required_for_event? and not render_default?
      errors.add :rendered_attributes, required_for_event_error_message
    end
  end

  def required_for_event?
    if section?
      full_set.any? do |field_or_section|
        field_or_section.read_attribute :required_for_event
      end
    else
      read_attribute :required_for_event
    end
  end

  def core_path
    self.key
  end

  def section?
    self.field_type == 'section'
  end

  def rendered?(disease)
    disease_associated?(disease) ? render_on_disease?(disease) : render_default?
  end

  def rendered_on_event?(event)
    disease = event.try(:disease_event).try(:disease)
    rendered? disease
  end

  def replaced?(event)
    disease = event.try(:disease_event).try(:disease)

    if assoc = disease_association(disease)
      assoc.replaced
    else
      if disease_specific
        return false
      else
        return true
      end
    end
  end

  def disease_association(disease)
    return if disease.nil?
    core_fields_diseases.select do |cfd|
      cfd.disease_id == disease.try(:id)
    end.first
  end

  def render_default?
    not disease_specific
  end

  def render_default=(value)
    self.disease_specific = !bool_cast(value)
  end

  def render_mode
    I18n.t render_default? ? :render_default? : :disease_specific
  end

  def rendered_attributes=(attributes)
    if attributes[:disease_id].blank?
      self.render_default = attributes[:rendered]
    else
      association = find_or_build_disease_association(:disease_id => attributes[:disease_id])
      association.rendered = attributes[:rendered]
      association.save!
    end
  end

  private

  def find_or_build_disease_association(options)
    unless disease = self.core_fields_diseases.first(:conditions => options)
      disease = self.core_fields_diseases.build(options)
    end
    disease
  end

  def bool_cast(value)
    disease_specific_column = column_for_attribute(:disease_specific)
    disease_specific_column.type_cast(value)
  end

  def normalize_attributes
    self.event_type = self.event_type.to_s if self.event_type
  end

  def render_on_disease?(disease)
    disease_association(disease).rendered
  end

  def disease_associated?(disease)
    not disease_association(disease).nil?
  end

  def required_for_event_error_message
    if section?
      I18n.t :contains_required_fields, :thing1 => I18n.t(:section_name, :name => name)
    else
      I18n.t :required_for, :thing1 => name, :thing2 => I18n.t(event_type.to_s.pluralize)
    end
  end

  class MissingCoreField < Struct.new(:key, :rendered_on_event, :help_text)
    include I18nCoreField
    alias core_path key
    def rendered_on_event?(event)
      self[:rendered_on_event]
    end
  end
end
