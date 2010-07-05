# Copyright (C) 2009, 2010, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition..

module TrisanoAuth
  module Models
    module User
      reloadable!
      hook! 'User'

      module ClassMethods
        def set_default_admin_uid_with_auth(uid, options={})
          auth_options = {
            :password => 'changeme',
            :password_confirmation => 'changeme',
          }
          options = options.merge(auth_options)
          set_default_admin_uid_without_auth(uid, options)
        end

        def load_default_users_with_auth(users)
          new_users = []
          
          users.each do |u|
            auth_options = {
              "password" => 'changeme',
              "password_confirmation" => 'changeme',
            }
            new_users << u.merge(auth_options)
          end

          load_default_users_without_auth(new_users)
        end
      end

      def self.included(base)
        #TODO debt
        unless config_option(:auth_src_env) || config_option(:auth_src_header)
          base.acts_as_authentic do |c|
            c.login_field = 'user_name'
            c.logged_in_timeout = 10.minutes
          end
          base.class_eval do
            extend ClassMethods
            class << self
              alias_method_chain :set_default_admin_uid, :auth
              alias_method_chain :load_default_users, :auth
            end
          end
        end
      end
    end
  end
end





