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

class CommonTestType < ActiveRecord::Base
  before_destroy :check_for_lab_results, :clear_loincs

  validates_uniqueness_of :common_name
  validates_length_of     :common_name, :in => 1..255

  has_many :loinc_codes
  has_many :disease_common_test_types
  has_many :diseases, :through => :disease_common_test_types
  has_many :lab_results, :foreign_key => :test_type_id

  def update_loinc_codes(options={})
    options = {:add => [], :remove => []}.merge(options)
    added   = extract_ids options[:add]
    removed = extract_ids options[:remove]
    LoincCode.transaction do
      LoincCode.update_all ['common_test_type_id = ?', self.id], ['id IN (?)', added]   unless added.empty?
      LoincCode.update_all  'common_test_type_id = NULL',        ['id IN (?)', removed] unless removed.empty?
    end
    self.loinc_codes.reset
  end

  def find_unrelated_loincs(search_keys={})
    sql = []
    conditions = []
    unless search_keys[:test_name].blank?
      sql << 'test_name ILIKE ?'
      conditions << "%#{search_keys[:test_name]}%"
    end
    unless search_keys[:loinc_code].blank?
      sql << 'loinc_code ILIKE ?'
      conditions << search_keys[:loinc_code] + "%"
    end
    if sql.empty?
      []
    else
      sql << '(common_test_type_id IS NULL OR common_test_type_id != ?)'
      conditions << self.id
      conditions.unshift sql.join(' AND ')
      LoincCode.find :all, :conditions => conditions, :order => 'loinc_code ASC', :include => [:common_test_type]
    end
  end

  private

  # grab all ids and ensure they are integers
  def extract_ids(objs_or_ids)
    if objs_or_ids.first.respond_to? :new_record?
      objs_or_ids.collect(&:id)
    else
      objs_or_ids.collect(&:to_i)
    end
  end

  def clear_loincs
    self.loinc_codes.clear
  end

  def check_for_lab_results
    raise DestroyNotAllowedError.new("#{self} already associated with lab results") unless self.lab_results.empty?
  end

  class DestroyNotAllowedError < Exception; end
end
