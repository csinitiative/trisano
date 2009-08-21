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

class LoincCode < ActiveRecord::Base
  default_scope :order => "lpad(loinc_code, 10, '0')"

  before_validation :strip_loinc

  validates_uniqueness_of :loinc_code
  validates_presence_of   :loinc_code
  validates_format_of     :loinc_code, :with => /^\d+-\d$/, :allow_blank => true, :message => "is invalid (should be nnnnn-n)"
  validates_length_of     :loinc_code, :maximum => 10,    :allow_blank => true

  validates_presence_of   :scale_id
  validates_length_of     :test_name,  :maximum => 255,   :allow_blank => true

  belongs_to :common_test_type
  belongs_to :scale, :class_name => 'ExternalCode'
  has_many   :disease_common_test_types, :foreign_key => :common_test_type_id, :primary_key => :common_test_type_id
  has_many   :diseases, :through => :disease_common_test_types

  named_scope :unrelated_to, lambda { |common_test_type|
    { :conditions => ['(common_test_type_id IS NULL OR common_test_type_id != ?)', common_test_type],
      :include    => [:common_test_type]
    }
  }

  def self.with_test_name_containing(value, &block)
    with_scope_unless value.blank?, :find => {:conditions => ['test_name ILIKE ?', "%#{value}%"]}, &block
  end

  def self.with_loinc_code_starting(value, &block)
    with_scope_unless value.blank?, :find => {:conditions => ['loinc_code ILIKE ?', "#{value}%"]}, &block
  end

  def self.search_unrelated_loincs(common_test_type, criteria={})
    return [] unless criteria.any?{ |k, v| not v.blank? }
    with_test_name_containing criteria[:test_name] do
      with_loinc_code_starting criteria[:loinc_code] do
        unrelated_to common_test_type
      end
    end
  end

  private

  def strip_loinc
    self.loinc_code.strip! if attribute_present? :loinc_code
  end
end
