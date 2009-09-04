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

class ExternalCode < ActiveRecord::Base

  belongs_to :jurisdiction, :class_name => 'Place', :foreign_key => :jurisdiction_id

  has_and_belongs_to_many :diseases

  named_scope :active, :conditions => 'deleted_at IS NULL', :order => 'sort_order, the_code'
  named_scope :case, :conditions => "code_name = 'case'"
  named_scope :loinc_scales, :conditions => {:code_name => 'loinc_scale'}, :order => 'sort_order, the_code'

  validates_presence_of :code_name
  validates_presence_of :the_code
  validates_presence_of :code_description
  validates_length_of :the_code, :maximum => 20
  validates_length_of :code_name, :maximum => 50
  validates_uniqueness_of :the_code, :scope => :code_name

  def self.yes
    find(:first, :conditions => "code_name = 'yesno' and the_code = 'Y'")
  end

  def self.no
    find(:first, :conditions => "code_name = 'yesno' and the_code = 'N'")
  end

  def self.yes_id
    yes.id if yes
  end

  def self.no_id
    no.id if no
  end

  def self.yesno
    active.find(:all, :conditions => "code_name = 'yesno'")
  end

  def self.telephone_location_types
    active.find_all_by_code_name('telephonelocationtype')
  end

  def self.telephone_location_type_ids
    telephone_location_types.collect{|code| code.id}
  end

  def self.age_type(age_description)
    with_scope(:find => {:conditions => "code_name='age_type'"}) do
      active.find(:first, :conditions => "code_description='#{age_description.to_s}'")
    end
  end

  def self.confirmed
    find :first, :conditions => "code_name = 'case' AND the_code = 'C'"
  end

  def self.probable
    find :first, :conditions => "code_name = 'case' AND the_code = 'P'"
  end

  def self.suspect
    find :first, :conditions => "code_name = 'case' AND the_code = 'S'"
  end

  def self.not_a_case
    find :first, :conditions => "code_name = 'case' AND the_code = 'NC'"
  end

  def self.chronic_carrier
    find :first, :conditions => "code_name = 'case' AND the_code = 'CC'"
  end

  def self.discarded
    find :first, :conditions => "code_name = 'case' AND the_code = 'D'"
  end

  def self.unknown
    find :first, :conditions => "code_name = 'case' AND the_code = 'UNK'"
  end

  def self.out_of_state
    find :first, :conditions => "code_name = 'case' AND the_code = 'OS'"
  end

  # Debt: This query bypasses AR because of an issue in acts_as_audible where
  # using an array in a condition was failing
  def self.find_codes_for_autocomplete(condition, limit=10)
    return [] if condition.nil?
    condition = sanitize_sql(["%s", condition.downcase])
    limit = sanitize_sql(["%s", limit])
    find_by_sql("SELECT * FROM external_codes WHERE deleted_at IS NULL AND LOWER(code_description) LIKE '#{condition}%' ORDER BY code_description LIMIT #{limit};")
  end

  def self.find_cases(*args)
    active.case.find(*args)
  end

  def self.loinc_scale_by_the_code(a_code)
    loinc_scales.find :first, :conditions => {:the_code => a_code}
  end

  def self.loinc_scale_nominal
    loinc_scale_by_the_code('Nom')
  end

  def deleted?
    not deleted_at.nil?
  end

  def soft_delete
    if self.deleted_at.nil?
      self.deleted_at = Time.new
      self.save(false)
    end
  end

  def soft_undelete
    if not self.deleted_at.nil?
      self.deleted_at = nil
      self.save(false)
    end
  end
end
