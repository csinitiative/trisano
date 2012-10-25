# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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
  extensible_helper

  def add_role_link(name)
    link_to_function name do |page|
      page.insert_html :after, :add_role_memberships, :partial => 'role', :object => RoleMembership.new
    end
  end

  def each_shortcut
      list = {
        :new => t("new_cmr_normal_case"),
        :cmr_search => t("search_normal_case"),
        :cmrs => t("view_edit_cmrs"),
        :navigate_right => t("navigate_right"),
        :navigate_left => t("navigate_left"),
        :save => t("navigate_to_save"),
        :settings => t("edit_settings"),
        :analysis => t("analysis")
      }

      admin = {
        :forms => t("view_edit_forms"),
        :admin => t("admin_dashboard")
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
      page.visual_effect :toggle_blind, 'sort-tools', :duration => 0.2
    end
  end

  def user_sort_by_select_tag
    options = [[t("uid"), "uid"], [t("status"), "status"], [t('user_name'), 'user_name']]
    select_tag :sort_by, options_for_select(options, params[:sort_by] || 'uid')
  end

  def user_menu_items(user)
    items = link_to(t('edit'), edit_user_path(user))
    items << " | "
    items << (link_to t('show'), user)
    return items
  end

  def render_settings_menu
    settings_menu.each do |section|
      haml_tag :h2 do
        haml_concat t(*section.first)
      end
      section.last.each do |item|
        haml_concat item
        haml_tag :br
      end
    end
  end

  def settings_menu
    [[:general,
      [ link_to(t(:edit_keyboard_shortcuts), shortcuts_edit_path),
        link_to(t(:manage_email_addresses), email_addresses_path),
        link_to(t(:event_display_option), event_settings_path)
      ]
    ]]
  end

end
