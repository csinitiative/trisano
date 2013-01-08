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
Given /a role named "(.+)"/ do |role_name|
  @role = Role.find_by_role_name(role_name)
  @role = Role.create!(:role_name => role_name) unless @role
end

Given /the role "(.+)" has the following privileges:$/ do |role_name, table|
  @role = Role.find_by_role_name(role_name)
  privilege_names = table.raw.map(&:first)
  privilege_ids = Privilege.all.select { |priv| privilege_names.include? priv.name}.map(&:id)
  @role.privilege_ids = privilege_ids
  @role.save!
end
