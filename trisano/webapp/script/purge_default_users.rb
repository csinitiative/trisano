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

user = nil
begin
  User.transaction do
    puts "Removing the default users"
    utah = User.find_by_uid("utah")
    det = User.find_by_uid("det")
    surveillance = User.find_by_uid("surveillance")
    investigator = User.find_by_uid("investigator")   
    lhd_mgr = User.find_by_uid("lhd_mgr")
    state_mgr = User.find_by_uid("state_mgr")
 
    if utah
      # ActiveRecord will trickle down and delete role_memberships and entitlements
      utah.destroy
      puts "Successfully removed user with uid 'utah'"
    else
      puts "User with uid of 'utah' not found"
    end

    if det
      # ActiveRecord will trickle down and delete role_memberships and entitlements
      det.destroy
      puts "Successfully removed user with uid 'det'"
    else
      puts "User with uid of 'det' not found"
    end

    if surveillance
      # ActiveRecord will trickle down and delete role_memberships and entitlements
      surveillance.destroy
      puts "Successfully removed user with uid 'surveillance'"
    else
      puts "User with uid of 'surveillance' not found"
    end

    if investigator
      # ActiveRecord will trickle down and delete role_memberships and entitlements
      investigator.destroy
      puts "Successfully removed user with uid 'investigator'"
    else
      puts "User with uid of 'investigator' not found"
    end

    if lhd_mgr
      # ActiveRecord will trickle down and delete role_memberships and entitlements
      lhd_mgr.destroy
      puts "Successfully removed user with uid 'lhd_mgr'"
    else
      puts "User with uid of 'lhd_mgr' not found"
    end

    if state_mgr
      # ActiveRecord will trickle down and delete role_memberships and entitlements
      state_mgr.destroy
      puts "Successfully removed user with uid 'state_mgr'"
    else
      puts "User with uid of 'state_mgr' not found"
    end
  end
rescue
  puts "Unable to delete user: #{$!}"
end
