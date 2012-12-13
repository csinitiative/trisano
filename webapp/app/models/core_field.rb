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

class CoreField < ActiveRecord::Base
  include I18nCoreField
  include Trisano::CorePathCallable

  acts_as_nested_set :scope => :tree_id if table_exists? && column_names.include?('tree_id')

  belongs_to :code_name
  has_many :core_fields_diseases, :dependent => :destroy, :autosave => true
  has_many :diseases, :through => :core_fields_diseases

  validates_uniqueness_of :key
  validates_presence_of :field_type
  validates_presence_of :event_type
  before_validation :normalize_attributes

  named_scope :default_follow_up_core_fields_for, lambda { |event_type|
    { :conditions => {
        :event_type => event_type,
        :can_follow_up => true,
        :disease_specific => false,
        :repeater => false
      }
    }
  }

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
      @tabs_cache = nil
    end

    def next_tree_id
      self.find_by_sql("SELECT nextval('core_field_tree_id_generator')").first.nextval.to_i
    end

    def load!(hashes)

      verify_no_duplicate_keys!(hashes)

      reset_column_information
      acts_as_nested_set(:scope => :tree_id) if table_exists? && column_names.include?('tree_id')

      transaction do
        hashes.each do |attributes|
          attributes.stringify_keys!
          unless self.find_by_key(attributes['key'])
            if (code_name = attributes.delete('code_name'))
              attributes['code_name'] = CodeName.find_by_code_name(code_name)
            end
            place_in_tree(attributes) do |attributes|
              CoreField.create!(attributes)
            end
          end
        end
      end
    end

    def verify_no_duplicate_keys!(hashes)
      keys = hashes.collect { |core_field_hash| core_field_hash["key"] }
      duplicates = keys.detect { |v| keys.count(v) > 1 }
      raise "Duplicate keys found in db/defaults/core_fields.yml: #{duplicates}" unless duplicates.blank?
    end

    def tabs_for(event_type)
      event_type = event_type.to_s
      tabs_cache[event_type] ||= CoreField.all(:conditions => {
                                                 :event_type => event_type,
                                                 :field_type => 'tab' },
                                               :order => 'lft ASC',
                                               :include => :core_fields_diseases)
      tabs_cache[event_type]
    end

    def tab(event_type, tab_name)
      event_fields(event_type)["#{event_type}[#{tab_name}]"]
    end

    # keep virtual attribute :rendered_attributes from being part of
    # error messages
    def human_attribute_name(attribute)
      return "" if attribute.to_sym == :rendered_attributes
      super
    end

    def repeaters_supported?
      column_names.include? 'repeater'
    end

    def nested_fields_supported?
      column_names.include? 'tree_id'
    end

    private

    def place_in_tree(attributes, &block)
      unless repeaters_supported?
        attributes.delete('repeater')
        attributes.delete('repeater_parent_key')
      end
      if nested_fields_supported?
        parent = find_parent(attributes)
        attributes['tree_id'] = parent ? parent.tree_id : next_tree_id
        core_field = block[attributes]
        parent.add_child(core_field) if parent
        core_field
      else
        attributes.delete('parent_key')
        block[attributes]
      end
    end

    def find_parent(attributes)
      parent_key = attributes.delete('parent_key')
      CoreField.find_by_key(parent_key) if parent_key
    end

    def event_fields_hash
      @event_fields_hash ||= {}
    end

    def tabs_cache
      @tabs_cache ||= {}
    end

  end

  def validate
    super
    unless render_default? and disease_associations_render?
      errors.add :rendered_attributes, required_for_event_error_message if required_for_event?
      errors.add :rendered_attributes, required_for_section_error_message if required_for_section?
    end
  end

  def required?
    required_for_section? or required_for_event?
  end

  def required_for_event?
    if self.class.nested_fields_supported? && container?
      full_set.any? do |field_or_section|
        field_or_section.read_attribute :required_for_event
      end
    else
      read_attribute :required_for_event
    end
  end

  def required_for_section?
    read_attribute :required_for_section
  end

  def disease_associations_render?
    core_fields_diseases.select(&:changed?).all?(&:rendered)
  end

  def core_path
    self.key
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
    attributes.symbolize_keys!
    if attributes[:disease_id].blank?
      self.render_default = attributes[:rendered]
    else
      association = find_or_build_disease_association(:disease_id => attributes[:disease_id])
      association.rendered = attributes[:rendered]
    end
  end

  def hidden?(disease)
    !rendered?(disease) || hidden_by_ancestry?(disease)
  end

  def hidden_by_ancestry?(disease)
    ancestors.any? { |ancestor| !ancestor.rendered?(disease) }
  end

  def morbidity_event?
    event_type == 'morbidity_event'
  end

  def section?
    field_type == 'section'
  end

  def tab?
    field_type == 'tab'
  end

  def event?
    field_type == 'event'
  end

  def container?
    section? or tab? or event?
  end

  private

  def required_for_event_error_message
    case
    when section?
      I18n.t :contains_required_fields, :thing1 => I18n.t(:section_name, :name => name)
    when tab?
      I18n.t :contains_required_fields, :thing1 => I18n.t(:tab_name, :name => name)
    else
      I18n.t :required_for, :thing1 => name, :thing2 => I18n.t(event_type.to_s.pluralize)
    end
  end

  def required_for_section_error_message
    I18n.t :required_for, :thing1 => name, :thing2 => I18n.t(:section_name, :name => parent.try(:name))
  end

  def find_or_build_disease_association(options)
    disease_association = core_fields_diseases.detect do |core_field_disease|
      !options[:disease_id].blank? and core_field_disease.disease_id == options[:disease_id].to_i
    end
    disease_association || core_fields_diseases.build(options)
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

  class MissingCoreField < Struct.new(:key, :rendered_on_event, :help_text)
    include I18nCoreField
    alias core_path key
    def rendered_on_event?(event)
      self[:rendered_on_event]
    end
  end
end
