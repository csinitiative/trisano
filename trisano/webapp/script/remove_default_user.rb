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

user = nil
begin
  User.transaction do
    puts "Removing the user with uid of 'utah'"
    user = User.find_by_uid("utah")
    
    if user
      # ActiveRecord will trickle down and delete role_memberships and entitlements
      user.destroy
    else
      raise "User with uid of 'utah' not found"
    end
  end
rescue
  puts "Unable to delete user: #{$!}"
else
  puts "Successfully removed user: #{user.user_name}"
end
