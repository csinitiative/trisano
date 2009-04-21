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

  named_scope :case, :conditions => "code_name = 'case'", :order => 'sort_order'

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
    find(:all, :conditions => "code_name = 'yesno'", :order => 'sort_order')
  end

  def self.unspecified_location_id
    code = find(:first, :conditions => "code_name = 'location' and the_code = 'UNK'")
    code.id unless code.nil?
  end

  def self.telephone_location_types
    find_all_by_code_name('telephonelocationtype', :order => 'sort_order')
  end

  def self.telephone_location_type_ids
    telephone_location_types.collect{|code| code.id}
  end

  def self.age_type(age_description)
    with_scope(:find => {:conditions => "code_name='age_type'"}) do
      find(:first, :conditions => "code_description='#{age_description.to_s}'")
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

  # Debt: This query bypasses AR because of an issue in acts_as_audible where
  # using an array in a condition was failing
  def self.find_codes_for_autocomplete(condition, limit=10)
    return [] if condition.nil?
    condition = sanitize_sql(["%s", condition.downcase])
    limit = sanitize_sql(["%s", limit])
    find_by_sql("select * FROM external_codes where LOWER(code_description) LIKE '#{condition}%' order by code_description limit #{limit};")
  end

  def self.find_cases(*args)
    with_scope(:find => {:conditions => "code_name = 'case'", :order => 'sort_order ASC'}) do
      find(*args)
    end
  end

end
