module Trisano
  module Locales
    module UserSelectedLocale
      module Helpers
        module LayoutHelper
          reloadable!
          extend_helper :layout_helper do
            alias_method_chain :render_user_tools, :locale_switcher
          end

          def render_user_tools_with_locale_switcher(user)
            returning "" do |result|
              result << render_locale_switcher if allow_locale_switching?
              result << render_user_tools_without_locale_switcher(user)
            end
          end

          def render_locale_switcher
            render :partial => 'default_locales/locale_selector'
          end

        end
      end
    end
  end
end
