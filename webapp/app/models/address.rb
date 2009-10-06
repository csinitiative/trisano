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

class Address < ActiveRecord::Base
  after_create :associate_longitudinal_data, :establish_canonical_address

  belongs_to :event
  belongs_to :entity
  belongs_to :county, :class_name => 'ExternalCode'
  belongs_to :district, :class_name => 'ExternalCode'
  belongs_to :state, :class_name => 'ExternalCode'

  validates_length_of :street_number, :maximum => 10, :allow_blank => true
  validates_length_of :street_name, :maximum => 50, :allow_blank => true
  validates_length_of :postal_code, :maximum => 10, :allow_blank => true
  validates_length_of :city, :maximum => 255, :allow_blank => true
  validates_length_of :unit_number, :maximum => 10, :allow_blank => true

  def number_and_street
    "#{self.street_number} #{street_name}".strip
  end

  def state_name   
    self.state.code_description if self.state
  end

  def district_name
    self.district.code_description if self.district
  end

  def county_name
    self.county.code_description if self.county
  end

  def formatted_address
    fa = number_and_street
    fa << ", Unit: #{self.unit_number}" unless self.unit_number.blank?
    fa << ", #{self.city}" unless self.city.blank?
    fa << ", #{self.state.the_code}" unless self.state.blank?
    fa << " #{self.postal_code}" unless self.postal_code.blank?
    fa << ". County: #{self.county.code_description}" unless self.county.blank?
    fa << ". District: #{self.district.code_description}" unless self.district.blank?
    fa
  end

  protected
  def validate
    if attributes.all? {|k, v| v.blank?}
      errors.add_to_base("At least one address field must have a value")
    end
  end

  def associate_longitudinal_data
    if event.respond_to?(:interested_party)
      if event.try(:interested_party).try(:primary_entity_id)
        update_attribute(:entity_id, event.interested_party.primary_entity_id)
      end
    end

    if event.respond_to?(:interested_place)
      if event.try(:interested_place).try(:primary_entity_id)
        update_attribute(:entity_id, event.interested_place.primary_entity_id)
      end
    end
  end

  def establish_canonical_address
    if event.respond_to?(:interested_place)
      if event.try(:interested_place).try(:primary_entity)
        if event.interested_place.primary_entity.canonical_address.nil?
          canonical_address = self.clone
          canonical_address.event_id = nil
          canonical_address.save
        end
      end
    end
    if event.respond_to?(:interested_party)
      if event.try(:interested_party).try(:person_entity)
        if event.interested_party.person_entity.canonical_address.nil?
          canonical_address = self.clone
          canonical_address.event_id = nil
          canonical_address.save
        end
      end
    end
  end

end
