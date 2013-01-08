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

class Telephone < ActiveRecord::Base
  include Trisano::Repeater
  belongs_to :entity
  belongs_to :entity_location_type, :class_name => 'ExternalCode'

  class << self
    def use?(field)
      telephone_options["use_#{field.to_s}"]
    end

    def regexp(field)
      Regexp.compile(telephone_options[field] || '')
    end

    def format(field)
      telephone_options["#{field.to_s}_format"]
    end

    def telephone_options
      {:use_phone_number => true, :use_extension => true}.merge(@telephone_options ||= config_options[:telephone]).with_indifferent_access
    end

    def telephone_options=(options)
      @telephone_options = options
    end
  end

  validates_format_of(:phone_number,
                      :with => regexp(:phone_number),
                      :message => :format,
                      :allow_blank => true)
  validates_format_of(:area_code,
                      :with => regexp(:area_code),
                      :message => :format,
                      :allow_blank => true,
                      :if => lambda { use?(:area_code) })
  validates_format_of(:extension,
                      :with => regexp(:extension),
                      :message => :format,
                      :allow_blank => true)
  validates_format_of(:country_code,
                      :with => regexp(:country_code),
                      :message => :format,
                      :allow_blank => true,
                      :if => lambda { use?(:country_code) })

  before_save :strip_dash_from_phone

  def xml_fields
    result = []
    result << [:entity_location_type_id, {:rel => :telephone_location_type}]
    result << :country_code if use?(:country_code)
    result << :area_code if use?(:area_code)
    result << :phone_number
    result << :extension
  end

  def simple_phone_number
    returning [] do |number|
      number << configurable_format(:country_code) if use?(:country_code)
      number << configurable_format(:area_code) if use?(:area_code)
      number << configurable_format(:phone_number)
      number << extension_format
    end.compact.join(' ')
  end

  # A basic (###) ###-#### Ext. # format for phone numbers
  def simple_format
    returning [] do |number|
      number << description_format
      number << simple_phone_number
    end.compact.join(' ')
  end

  def validate
    if attributes.all? {|k, v| v.blank?}
      errors.add_to_base(:all_blank)
    end
  end

  def strip_dash_from_phone
    if !phone_number.blank?
      phone_number.gsub!(/-/, '')
    end
  end

  def description_format
    return if entity_location_type.blank?
    "#{entity_location_type.code_description}:"
  end

  def extension_format
    return if extension.blank?
    "#{I18n.t('extension_abbrev')} #{extension}"
  end

  def configurable_format(field)
    return if send(field).blank?
    format = format(field)
    return send(field) if format.blank?
    begin
      format % matches(field)
    rescue ArgumentError => e
      I18nLogger.error(:phone_format_mismatch)
      return send(field)
    end
  end

  def use?(field)
    self.class.use?(field)
  end

  def regexp(field)
    self.class.regexp(field)
  end

  def matches(field)
    regexp(field).match(send(field)).try(:captures) || []
  end

  def format(field)
    self.class.format(field)
  end
end
