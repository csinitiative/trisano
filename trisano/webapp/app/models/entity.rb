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

class Entity < ActiveRecord::Base
  has_many :people

  #TODO: TGF DELETE THESE WHEN DONE WITH REFACTORING
  has_many :places, :order => 'created_at ASC'
  has_one  :current_place, :class_name => 'Place', :order => 'created_at DESC'

  #TODO: TGF CHANGE PLACE_TEMP TO PLACE WHEN REFACTORING COMPLETE
  has_one :place_temp, :class_name => "Place"
  has_one :person_temp, :class_name => "Person"

  has_many :entities_locations, :foreign_key => 'entity_id', 
                                :select => "DISTINCT ON (entity_id, entity_location_type_id, primary_yn_id, location_type_id) *", 
                                :order => 'entity_id, entity_location_type_id, primary_yn_id, location_type_id, created_at DESC'
  has_many :locations, :through => :entities_locations

  has_many :telephone_entities_locations,
    :class_name => 'EntitiesLocation',
    :foreign_key => 'entity_id',
    :conditions => ["location_type_id = ?", Code.telephone_location_type_id],
    :order => 'created_at ASC'
  
  has_many :address_entities_locations,
    :class_name => 'EntitiesLocation',
    :foreign_key => 'entity_id',
    :conditions => ["location_type_id = ?", Code.address_location_type_id],
    :order => 'created_at ASC'
  
  has_and_belongs_to_many :races, 
    :class_name => 'ExternalCode', 
    :join_table => 'people_races', 
    :association_foreign_key => 'race_id', 
    :order => 'code_description'

  attr_protected :entity_type

  # Turn off auto validation of has_many associations
  def validate_associated_records_for_people() end
  def validate_associated_records_for_places() end
  def validate_associated_records_for_telephone_entities_locations() end
  def validate_associated_records_for_address_entities_locations() end

  validates_presence_of :entity_type
  validates_associated :people
  validates_associated :place_temp
  validates_associated :person_temp
  validates_associated :telephone_entities_locations
  validates_associated :address_entities_locations

  after_update :save_associations

  def person
    person_temp
  end

  def person=(attributes)
    self.build_person_temp if self.person_temp.nil?
    self.entity_type = 'person'
    person_temp.attributes = attributes
  end  

  def place
    place_temp
  end

  def place=(attributes)
    self.build_place_temp if self.place_temp.nil?
    self.entity_type = 'place'
    place_temp.attributes = attributes
  end

  def address
    self.address_entities_locations.empty? ? nil : self.address_entities_locations.last.location.addresses.last
  end

  def address=(attributes)
    return if attributes.values_blank?

    if self.address_entities_locations.empty?
      self.address_entities_locations.build( 
        :primary_yn_id => ExternalCode.yes.id,
        :location_type_id => Code.address_location_type_id).build_location.addresses.build
    end
    address_entities_locations.last.location.addresses.last.attributes = attributes
  end  

  # For backwards compatibility.  Can be removed when formbuilder usage is purged.
  def telephone_entities_location
    self.telephone_entities_locations.last
  end

  def new_telephone_attributes=(phone_attributes)
    phone_attributes.each do |attributes|
      code = attributes.delete(:entity_location_type_id)
      next if attributes.values_blank?
      el = self.telephone_entities_locations.build(
             :entity_location_type_id => code, 
             :primary_yn_id => ExternalCode.no_id,
             :location_type_id => Code.telephone_location_type_id)
      el.build_location.telephones.build(attributes)
    end
  end

  def existing_telephone_attributes=(phone_attributes)
    self.telephone_entities_locations.reject(&:new_record?).each do |el|
      attributes = phone_attributes[el.id.to_s]
      if attributes
        el.entity_location_type_id = attributes.delete(:entity_location_type_id)
        el.location.telephones.last.attributes = attributes
      else
        el.location.destroy
      end
    end
  end
  
  # For backwards compatibility.  Can be removed when formbuilder usage is purged.
  def telephone
    return nil if self.telephone_entities_locations.empty?
    self.telephone_entities_locations.last.location.telephones.last
  end

  def case_id
    return nil if new_record?
    primary_entity = Participation.find_by_primary_entity_id(id)
    case_id = primary_entity.event_id unless primary_entity.nil?
    case_id.nil? ? nil : case_id
  end

  private

  def save_associations
    # Debt: break these out when Entity is STI enabled as PersonEntity, PlaceEntity, etc.
    self.person_temp.save(false) if person_temp
    self.place_temp.save(false) if place_temp

    self.address_entities_locations.each do |al|
      al.save(false)
      al.location.save(false)
      al.location.addresses.each {|a| a.save(false)}
    end

    self.telephone_entities_locations.each do |el|
      el.save(false)           
      el.location.save(false)
      # el.location.telephones.each {|t| t.save(false) unless t.frozen?}
      el.location.telephones.each {|t| t.save(false)}
    end
  end

end
