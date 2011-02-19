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
    module LayoutHelper
      reloadable!
      extend_helper :layout_helper

      def self.included(base)
        base.class_eval do
          alias_method_chain :main_menu_items, :auth
        end
      end

      def main_menu_items_with_auth
        returning main_menu_items_without_auth do |items|
          items << {:link => logout_path, :t => [:logout, {:scope => :trisano_auth}]} if User.current_user
        end
      end

    end
  end
end
