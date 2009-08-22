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

module UsersHelper
  
  def add_role_link(name)
    link_to_function name do |page|
      page.insert_html :top, :role_memberships, :partial => 'role', :object => RoleMembership.new
    end
  end

  def each_shortcut
      list = {
        :new => "New CMR",
        :cmr_search => "Search",
        :cmrs => "View/Edit CMRs",
        :navigate_right => "Move One Tab Right",
        :navigate_left => "Move One Tab Left",
        :save => "Highlight 'Save & Exit'",
        :settings => "Edit User Settings",
        :analysis => "Analysis"
      }

      admin = {
        :forms => "View/Edit Forms",
        :admin => "Admin Dashboard"
      }

      list.each do |label|
          yield label
      end

      if User.current_user.is_admin?
          admin.each do |l2|
              yield l2
          end
      end
  end 

  def link_to_toggle_sort_tools(text)
    link_to_function text, nil do |page|
      page.visual_effect :toggle_blind, 'sort-tools'
    end
  end

end
