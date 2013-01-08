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

class MakeEmailAddressOwnerPolymorphic < ActiveRecord::Migration
  def self.up
    transaction do
      rename_column :email_addresses, :entity_id, :owner_id
      add_column :email_addresses, :owner_type, :string
      EmailAddress.all.each do |email_address|
        email_address.update_attribute :owner_type, 'Entity'
      end
    end
  end

  def self.down
    transaction do
      remove_column :email_addresses, :owner_type
      rename_column :email_addresses, :owner_id, :entity_id
    end
  end
end
