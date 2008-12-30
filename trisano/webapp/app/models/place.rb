# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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
  belongs_to :place_type, :class_name => 'Code'
  belongs_to :entity 
  has_many :reporting_agency_types
  has_many :agency_types, :through => :reporting_agency_types, :source => :code

  validates_presence_of :name

  class << self

    # TODO:  Does not yet take into account multiple edits of a single hospital.  Can probably be optimized.
    def hospitals
      find_all_by_place_type_id(Code.find_by_code_name_and_the_code('placetype', 'H').id, :order => 'name')
    end

    def jurisdictions
      jurisdictions = find_all_by_place_type_id(Code.find_by_code_name_and_code_description('placetype', 'Jurisdiction').id, :order => 'name')

      # Pull 'Unassigned' out and place it on top.
      unassigned = jurisdictions.find { |jurisdiction| jurisdiction.name == "Unassigned" }
      jurisdictions.unshift( jurisdictions.delete( unassigned ) ) unless unassigned.nil?
      jurisdictions
    end

    def jurisdiction_by_name(name)
      find_by_name_and_place_type_id(name, Code.find_by_code_name_and_the_code("placetype", "J").id)
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

    def agency_types
      Code.find(:all, 
                :conditions => ['code_name = ? AND the_code IN (?)', 'placetype', agency_type_codes],
                :order => 'sort_order ASC')
    end
  end

  def place_description
    place_type.code_description if place_type
  end

  def agency_types_description
    unless agency_types.empty?
      agency_types.sort_by(&:sort_order).collect {|type| type.code_description}.to_sentence :skip_last_comma => true
    else
      place_type.code_description unless place_type.nil?
    end
  end
end
