module TrisanoAuth
  module Controllers
    module AdminController
      hook! "AdminController"
      reloadable!

      class << self
        def included(base)
          base.before_filter :manage_passwords_links
          base.helper_method :trisano_auth_scope
        end
      end

      protected

      def manage_passwords_links
        system_configuration_links << {
          :description => I18n.t('manage_passwords_link', :scope => trisano_auth_scope),
          :link => password_resets_path
        } if User.current_user.is_admin?
      end

      private

      def trisano_auth_scope
        [:trisano_auth]
      end
    end
  end
end

