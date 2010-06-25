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
