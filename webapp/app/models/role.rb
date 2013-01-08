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

class Role < ActiveRecord::Base

  has_many :role_memberships, :dependent => :delete_all
  has_many :users, :through => :role_memberships

  has_many :privileges_roles, :dependent => :delete_all
  has_many :privileges, :through => :privileges_roles

  validates_presence_of :role_name
  validates_length_of :role_name, :maximum => 100, :allow_blank => true

  def privileges_role_attributes=(pr_attributes)
    privileges_roles.clear

    _privileges_roles = []

    pr_attributes.each do |attributes|
      privilege_id = attributes[:privilege_id]

      # Skip duplicate roles in duplicate jurisdictions
      next if _privileges_roles.include?(privilege_id)
      _privileges_roles << privilege_id

      privileges_roles.build(attributes)
    end
  end

end
