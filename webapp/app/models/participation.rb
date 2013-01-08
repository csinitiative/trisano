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

class Participation < ActiveRecord::Base
  belongs_to :event
  belongs_to :primary_entity, :foreign_key => :primary_entity_id, :class_name => 'Entity'
  belongs_to :secondary_entity, :foreign_key => :secondary_entity_id, :class_name => 'Entity'

  def validate
    unless primary_entity.nil?
      add_merge_error unless primary_entity.deleted_at.nil?
    end

    unless secondary_entity.nil?
      add_merge_error unless secondary_entity.deleted_at.nil?
    end
  end

  private

  def associate_longitudinal_data
    if event.try(:address)
      event.address.update_attribute(:entity_id, primary_entity_id)
    end
  end

  def copy_canonical_address
    canonical_address = primary_entity.canonical_address
    if (!canonical_address.nil? && event.address.nil?)
      primary_entity.addresses.create({
          :event_id => event_id,
          :street_number => canonical_address.street_number,
          :street_name => canonical_address.street_name,
          :unit_number => canonical_address.unit_number,
          :city => canonical_address.city,
          :county_id => canonical_address.county_id,
          :state_id => canonical_address.state_id,
          :postal_code => canonical_address.postal_code
        })
    end
  end

  # Establishes a base error message for the merge race condition error. Sub-classes can override for a more
  # specific error message.
  def add_merge_error
    if self.respond_to?(:place_entity)
      add_place_specific_merge_error(:merge_race_error)
    else
      errors.add(:base, :merge_race_error)
    end
  end

  def add_place_specific_merge_error(base_message)
    if self.place_entity.place.nil?
      errors.add(:base, base_message)
    else
      errors.add("#{self.place_entity.place.name}", base_message)
    end
  end

end
