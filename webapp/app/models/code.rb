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

class Code < ActiveRecord::Base

  validates_presence_of :code_name
  validates_presence_of :the_code
  validates_presence_of :code_description
  validates_length_of :the_code, :maximum => 20
  validates_length_of :code_name, :maximum => 50
  validates_uniqueness_of :the_code, :scope => :code_name

  named_scope :active, :conditions => 'deleted_at IS NULL', :order => 'sort_order' do
    def exclude_jurisdiction
      delete_if { |c| c.code_name == 'placetype' && c.the_code == 'J' }
    end
  end

  named_scope :placetypes, :conditions => {:code_name => 'placetype'}, :order => 'sort_order, the_code'

  def self.other_place_type_id
    safe_table_access do
      @@telephone_location_type ||= find_by_code_name_and_the_code 'placetype', '0'
      @@other_place_type.id unless @@other_place_type.nil?
    end
  end

  def self.telephone_location_type_id
    safe_table_access do
      @@telephone_location_type ||= find_by_code_name_and_the_code 'locationtype', 'TLT'
      @@telephone_location_type.id if @@telephone_location_type
    end
  end

  def self.address_location_type_id
    safe_table_access do
      @@address_location_type ||= find_by_code_name_and_the_code 'locationtype', 'ALT'
      @@address_location_type.id if @@address_location_type
    end
  end

  def self.jurisdiction_place_type_id
    safe_table_access do
      jurisdiction_place_type.id if jurisdiction_place_type
    end
  end

  def self.jurisdiction_place_type(reload=false)
    @@jurisdiction_place_type = nil if reload
    safe_table_access do
      @@jurisdiction_place_type ||= find_jurisdiction_place_type
    end
  end

  def self.lab_place_type
    safe_table_access do
      @@lab_place_type ||= find_by_code_name_and_the_code 'placetype', 'L'
    end
  end

  def self.lab_place_type_id
    self.lab_place_type.id if self.lab_place_type
  end

  def self.load!(hashes)
    transaction do
      attributes = Code.new.attribute_names
      hashes.each do |attrs|
        raise "Could not find code name #{attrs["code_name"]}" unless CodeName.find_by_code_name(attrs["code_name"])
        unless self.find_by_code_name_and_the_code(attrs["code_name"], attrs["the_code"])
          load_attrs = attrs.reject { |key, value| !attributes.include?(key) }
          Code.create!(load_attrs)
        end
      end
    end
  end

  private

  def self.safe_table_access
    begin
      return yield if block_given?
    rescue
      logger.error "Error reading from the codes table. This sometimes happens when running rake"
    ensure
      nil
    end
  end

  def self.find_jurisdiction_place_type
    find_by_code_name_and_the_code 'placetype', 'J'
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
