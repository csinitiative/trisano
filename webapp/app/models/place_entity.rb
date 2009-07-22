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

class PlaceEntity < Entity
  has_one :place, :foreign_key => "entity_id", :class_name => "Place"
  accepts_nested_attributes_for :place, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }, :allow_destroy => true

  def self.find_for_entity_managment(search_params)
    if search_params[:participation_type].blank?
      conditions = ["LOWER(name) LIKE ? AND entities.deleted_at IS NULL", '%' + search_params[:name].downcase + '%']

      PlaceEntity.find(:all, :select => "DISTINCT(entities.id), places.name",
        :include => [:place, :canonical_address],
        :conditions => conditions,
        :joins => "LEFT OUTER JOIN places ON places.entity_id = entities.id LEFT OUTER JOIN places_types ON places_types.place_id = places.id LEFT OUTER JOIN codes ON places_types.type_id = codes.id",
        :order => "places.name ASC"
      )
    else
      PlaceEntity.all_by_name_and_participation_type(search_params)
    end
  end

  def self.all_by_name_and_participation_type(search_params)
    entity_id = (search_params[:participation_type] == "InterestedPlace") ? "primary_entity_id" : "secondary_entity_id"
    conditions = ["participations.type = ? AND places.name ilike ? AND entities.deleted_at IS NULL", search_params[:participation_type], '%' + search_params[:name] + '%']

    PlaceEntity.find(:all, :select => "DISTINCT(entities.id), places.name",
      :include => [:place, :canonical_address],
      :conditions => conditions,
      :joins => "INNER JOIN places ON entities.id = places.entity_id INNER JOIN participations ON entities.id = participations.#{entity_id}",
      :order => "places.name ASC"
    )
  end
  
end
