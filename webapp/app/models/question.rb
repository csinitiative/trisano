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

class Question < ActiveRecord::Base

  belongs_to :question_element, :foreign_key => "form_element_id"

  class << self
    def data_type_array
      [
        [I18n.t('question_data_types.single_line_text'), "single_line_text"],
        [I18n.t('question_data_types.multi_line_text'), "multi_line_text"],
        [I18n.t('question_data_types.drop_down'), "drop_down"],
        [I18n.t('question_data_types.radio_button'), "radio_button"],
        [I18n.t('question_data_types.check_box'), "check_box"],
        [I18n.t('question_data_types.date'), "date"],
        [I18n.t('question_data_types.phone'), "phone"]
      ]
    end

    def valid_data_types
      @valid_data_types ||= data_type_array.map { |data_type| data_type.last }
    end
  end

  validates_presence_of :question_text, :short_name
  validates_presence_of :data_type, :unless => :core_data
  validates_presence_of :core_data_attr, :if => :core_data
  validates_length_of :question_text, :maximum => 1000, :allow_blank => true
  validates_length_of :help_text, :maximum => 1000, :allow_blank => true

  before_validation :sanitize_short_name
  before_update :short_name_filter

  def data_type
    read_attribute("data_type").to_sym unless read_attribute("data_type").blank?
  end

  def is_multi_valued?
    self.data_type == :drop_down || self.data_type == :radio_button || self.data_type == :check_box
  end

  def validate
    # Bypassing validates_inclusion_of in order to work around the data_type to_sym method
    unless Question.valid_data_types.include? data_type.to_s
      errors.add(:data_type, :invalid) if core_data.blank?
    end
  end

  def repeater?
    question_element.core_field_repeater?
  end

  private

  def sanitize_short_name
    self.short_name = self.short_name.strip.gsub(/ /, '_') unless self.short_name.blank?
  end

  def short_name_filter
    if self.short_name_changed?
      unless (question_element.nil? || question_element.form.nil?)
        self.short_name = self.short_name_was unless question_element.short_name_editable?
      end
    end
  end

end
