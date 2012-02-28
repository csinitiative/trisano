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
            c.logged_in_timeout = config_options[:trisano_auth][:login_timeout].minutes
            password_reset_token_valid_for = config_options[:trisano_auth][:password_reset_timeout].days
            c.perishable_token_valid_for 1.day

            password_length_constraints = c.validates_length_of_password_field_options.reject { |k,v| [:minimum, :maximum].include?(k) }
            c.validates_length_of_password_field_options = password_length_constraints.merge :within => 0..64

            c.validates_format_of :password, :with => /^(?!.*(.)\1)(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[^0-9a-zA-Z])([\x20-\x7E]){7,}$/, :if => :require_password?, :message => "must be at least 7 characters.  It must include a number, a lower case letter, an upper case character, and a non-alphanumeric character.  No two characters may be repeated sequentially."
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





