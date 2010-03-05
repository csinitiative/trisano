module Trisano
  module Locales
    module Controllers
      module AdminController
        hook! "AdminController"
        reloadable!

        class << self
          def included(base)
            base.before_filter :manage_locale_links
            base.helper_method :trisano_locale_scope
          end
        end

        protected

        def manage_locale_links
          system_configuration_links << {
            :description => I18n.t('manage_locale_link', :scope => trisano_locale_scope),
            :link => default_locale_path
          } if User.current_user.is_entitled_to?(:manage_locales)
        end

        private

        def trisano_locale_scope
          [:trisano_locales]
        end
      end
    end
  end
end
