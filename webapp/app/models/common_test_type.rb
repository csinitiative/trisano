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
  validates_uniqueness_of :common_name
  validates_length_of     :common_name, :in => 1..255

  has_many :loinc_codes
  has_many :disease_common_test_types
  has_many :diseases, :through => :disease_common_test_types

  def update_loinc_codes(options={})
    options = {:add => []}.merge(options)
    added = options[:add]
    if added.first.respond_to? :new_record?
      added = added.collect(&:id)
    else
      added = added.collect(&:to_i)
    end
    self.loinc_code_ids += added
    self.loinc_code_ids.uniq!
    self.save!
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
end
