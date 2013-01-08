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

class Entity < ActiveRecord::Base
  set_inheritance_column :entity_type

  has_many :telephones, :order => "updated_at"
  has_many :email_addresses, :order => "updated_at", :as => :owner
  has_many :addresses

  has_one :canonical_address, :foreign_key => "entity_id", :class_name => "Address", :conditions => {:event_id => nil}
  has_one :place
  has_one :person

  accepts_nested_attributes_for :canonical_address, :reject_if => :nested_attributes_blank?
  accepts_nested_attributes_for :addresses, :reject_if => :nested_attributes_blank?, :allow_destroy => true
  accepts_nested_attributes_for :telephones, :email_addresses, :reject_if => :nested_attributes_blank?, :allow_destroy => true

  attr_protected :entity_type

  named_scope :exclude_deleted, :conditions => "deleted_at is NULL"
  named_scope :exclude_entity, lambda { |entity|
    { :conditions => ["entities.id != ?", entity] }
  }

  def formatted_address
    addr = canonical_address || addresses.first
    addr.blank? ? "" : addr.formatted_address
  end

  def primary_phone
    self.telephones.first
  end

  def validate
    errors.add(:base, :incomplete) if (person.nil? and place.nil?)
  end

end
