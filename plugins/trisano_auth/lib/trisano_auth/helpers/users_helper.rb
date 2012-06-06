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

module TrisanoAuth
  module Helpers
    module UsersHelper
      reloadable!
      extend_helper :users_helper do
        alias_method_chain :user_menu_items, :auth
        alias_method_chain :settings_menu, :auth
      end

      def user_menu_items_with_auth(user)
        returning user_menu_items_without_auth(user) do |items|
          items << " | "
          items << (link_to t('trisano_auth.reset_password'), new_password_reset_path(:user_id => user.id))
        end
      end
      
      def settings_menu_with_auth
        menu = settings_menu_without_auth
        menu.each do |section|
          if section.first == :general
            section.second << link_to(t("trisano_auth.api_key"), api_key_path)
            section.second << link_to(t("trisano_auth.change_password"), change_password_url)
          end
        end
      end

    end
  end
end
