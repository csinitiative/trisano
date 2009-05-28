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

class Place < ActiveRecord::Base
  belongs_to :entity 
  has_and_belongs_to_many :place_types, 
    :foreign_key => 'place_id',
    :class_name => 'Code', 
    :join_table => 'places_types', 
    :association_foreign_key => 'type_id', 
    :order => 'code_description'

  validates_presence_of :name

  class << self

    # TODO:  Does not yet take into account multiple edits of a single hospital.  Can probably be optimized.
    def hospitals(unique=false)
      if unique
        select = "DISTINCT ON (name) *)"
      else
        select = "*"
      end
      self.all_by_place_code('H', select)
    end

    def jurisdictions
      jurisdictions = self.all_by_place_code('J')

      # Pull 'Unassigned' out and place it on top.
      unassigned = jurisdictions.find { |jurisdiction| jurisdiction.name == "Unassigned" }
      jurisdictions.unshift( jurisdictions.delete( unassigned ) ) unless unassigned.nil?
      jurisdictions
    end

    def jurisdiction_by_name(name)
      all_by_name_and_types(name, 'J').first
    end

    def labs_by_name(name)
      all_by_name_and_types(name, 'L')
    end

    def all_by_name_and_types(name, type_codes, short_name=false)
      type_codes = [ type_codes ] unless type_codes.is_a?(Array)
      self.all(:include => :place_types, 
               :conditions => [ "LOWER(places.#{short_name ? 'short_name' : 'name'}) = ? AND codes.the_code IN (?) AND codes.code_name = 'placetype'", name.downcase, type_codes ],
               :order => "LOWER(TRIM(name))")
    end

    def jurisdictions_for_privilege_by_user_id(user_id, privilege)
      query = "
        SELECT
                places.id, places.entity_id, places.name, places.short_name
        FROM
                users,
                entitlements,
                privileges,
                entities, 
                places
        WHERE
                users.id = entitlements.user_id
        AND
                privileges.id = entitlements.privilege_id
        AND
                entitlements.jurisdiction_id = entities.id
        AND
                places.entity_id = entities.id
        AND
                users.id = '#{user_id}'
        AND
                privileges.priv_name = '#{privilege.to_s}' 
        ORDER BY
                places.name"

      jurisdictions = find_by_sql(query)
      unassigned = jurisdictions.find { |jurisdiction| jurisdiction.name == "Unassigned" }
      jurisdictions.unshift( jurisdictions.delete( unassigned ) ) unless unassigned.nil?
      jurisdictions
    end

    def agency_type_codes
      %w(H L C O S DC CF LCF PUB OOS)
    end

    def diagnostic_type_codes
      %w(H L C O S OOS)
    end

    def epi_type_codes
      %w(S P FE DC RA E CF LCF GLE)
    end

    def agency_types
      place_types(agency_type_codes)
    end

    def diagnostic_types
      place_types(diagnostic_type_codes)
    end
    
    def epi_types
      place_types(epi_type_codes)
    end
    
    def place_types(type_codes)
      Code.find(:all, 
                :conditions => ['code_name = ? AND the_code IN (?)', 'placetype', type_codes],
                :order => 'sort_order ASC')
    end

    def all_by_place_code(code, select=nil)
      self.all(:select => select || "*", :include => :place_types, :conditions => "codes.the_code = '#{code}' AND codes.code_name = 'placetype'", :order => 'name')
    end
  end

  def place_descriptions
    place_types.sort_by(&:sort_order).collect { |pt| pt.code_description }
  end

  def formatted_place_descriptions
    place_descriptions.to_sentence
  end
end
