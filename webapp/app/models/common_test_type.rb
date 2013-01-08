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

class CommonTestType < ActiveRecord::Base
  before_destroy :check_for_lab_results, :clear_loincs

  validates_uniqueness_of :common_name, :case_sensitive => false
  validates_length_of     :common_name, :in => 1..255

  has_many :loinc_codes
  has_many :common_test_types_diseases
  has_many :diseases, :through => :common_test_types_diseases
  has_many :lab_results, :foreign_key => :test_type_id

  class << self
    def load_from_csv(str_or_readable)
      require 'csv'
      transaction do
        CSV.parse str_or_readable do |row|
          conditions = {:common_name => row.first}
          CommonTestType.first(:conditions => conditions) || CommonTestType.create!(conditions)
        end
      end
    end
  end

  def update_loinc_code_ids(options={})
    options = {:add => [], :remove => []}.merge(options)
    added   = options[:add]
    removed = options[:remove]
    LoincCode.transaction do
      LoincCode.update_all ['common_test_type_id = ?', self.id], ['id IN (?)', added]   unless added.empty?
      LoincCode.update_all  'common_test_type_id = NULL',        ['id IN (?)', removed] unless removed.empty?
    end
    self.loinc_codes.reset
    true
  end

  private

  def clear_loincs
    self.loinc_codes.clear
  end

  def check_for_lab_results
    raise DestroyNotAllowedError.new(I18n.t("common_test_type_associated_with_lab_results", :name => self)) unless self.lab_results.empty?
  end

  class DestroyNotAllowedError < Exception; end
end
