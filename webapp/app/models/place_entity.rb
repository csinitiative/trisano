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

class PlaceEntity < Entity
  has_one :place, :foreign_key => "entity_id", :class_name => "Place", :dependent => :destroy
  has_one :entity, :through => :place
  accepts_nested_attributes_for :place, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }, :allow_destroy => true

  named_scope :jurisdictions,
              :joins => "INNER JOIN places p on entities.id = p.entity_id INNER JOIN places_types on p.id = places_types.place_id INNER JOIN codes on places_types.type_id = codes.id",
              :conditions => "codes.the_code = 'J' AND codes.code_name = 'placetype'",
              :order => 'p.name',
              :readonly => false

  named_scope :labs,
              :joins => "INNER JOIN places p on entities.id = p.entity_id INNER JOIN places_types on p.id = places_types.place_id INNER JOIN codes on places_types.type_id = codes.id",
              :conditions => "codes.the_code = 'L' AND codes.code_name = 'placetype'",
              :order => 'p.name',
              :include => :place,
              :readonly => false

  named_scope :active,
              :conditions => "entities.deleted_at IS NULL"


  # Intended to be chained to one of the other jurisdiction named scopes
  named_scope :excluding_unassigned,
    :conditions => "p.name != 'Unassigned'"

  named_scope :by_place_name, lambda { |place_name|
    { :joins => "INNER JOIN places p on entities.id = p.entity_id",
      :conditions => ["p.name = ? and entities.deleted_at IS NULL", place_name]
    }
  }

  named_scope :with_short_name, lambda { |short_name|
    { :conditions => ["p.short_name = ?", short_name] } }

  named_scope :with_place_names_like, lambda { |place_name|
    { :joins => ["INNER JOIN places p on entities.id = p.entity_id"],
      :conditions => ["p.name ILIKE ? AND entities.deleted_at IS NULL", '%' + place_name + '%']
    }
  }

  named_scope :join_participations, lambda { |participation_type|
    { :joins => "LEFT JOIN participations ON entities.id = participations.#{participation_type == 'InterestedPlace' ? 'primary_entity_id' : 'secondary_entity_id'}" }
  }

  named_scope :limit_by_place_types, lambda { |types|
    { :conditions => ["codes.the_code IN (?)", types] }
  }

  named_scope :limit_by_place_or_participation_types, lambda { |place_types, participation_type|
    { :conditions => ["codes.the_code IN (?) OR participations.type = ?", place_types, participation_type] }
  }

  # Used to decrease number of queries executed when diplaying a place
  # listing. Should be combined with other place scopes.
  named_scope :optimize_for_index, {
    :include => [{:place => :place_types}, {:canonical_address => [:county, :state]}],
    :select => "DISTINCT(entities.id), p.name",
    :order => "p.name ASC"
  }

  # builds a scoped object, like what is returned from named_scopes
  def self.by_name_and_participation_type(search_data)
    scope = optimize_for_index
    if search_data.includes_place_type?
      if search_data.includes_participation_type?
        scope = scope.join_participations(search_data.participation_type)
        scope = scope.limit_by_place_or_participation_types(search_data.place_types, search_data.participation_type)
      else
        scope = scope.limit_by_place_types(search_data.place_types)
      end
    end
    scope = scope.with_place_names_like(search_data.name)
    scope
  end

  # Convenience method to allow a place entity's place name to be accessible through
  # the place entity directly, enabling things like collection_select to work easily.
  def name
    place.name unless place.nil?
  end

end
