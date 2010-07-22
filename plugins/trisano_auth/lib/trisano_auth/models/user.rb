# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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
        
        def new(params = nil)
          user = super(params)
          random_string = ActiveSupport::SecureRandom.hex(16)
          
          user.password = random_string
          user.password_confirmation = random_string
          
          return user
        end
      end

      def self.included(base)
        #TODO debt
        unless config_option(:auth_src_env) || config_option(:auth_src_header)
          base.acts_as_authentic do |c|
            c.login_field = 'user_name'
            c.logged_in_timeout = 10.minutes
            c.perishable_token_valid_for 1.day
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





