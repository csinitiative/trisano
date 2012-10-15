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

      module InstanceMethods

        def initialize_tokens
          self.perishable_token = Authlogic::Random.friendly_token
        end

      end

      module ClassMethods

        def set_default_admin_uid_with_auth(uid, options={})
          auth_options = {
            :password => config_option(:default_admin_password),
            :password_confirmation => config_option(:default_admin_password)
          }
          options = options.merge(auth_options)
          set_default_admin_uid_without_auth(uid, options)
        end

        def load_default_users_with_auth(users)
          new_users = []
          
          users.each do |u|
            auth_options = {
              "password" => config_option(:default_user_password),
              "password_confirmation" => config_option(:default_user_password)
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
        if (config_option(:auth_src_env) || config_option(:auth_src_header)).nil? || RAILS_ENV == "feature"
          def require_password_changed?
            !new_record? && password_changed?
          end

          def require_current_password_changed?
            @current_password_changed
          end

          def current_password?
            unless self.valid_password?(self.current_password, true)
              self.errors.add_to_base "Current password is invalid."
            end
          end

          def password_repeated?
            return if self.password.blank?
            arguments_type = act_like_restful_authentication? ? :restful_authentication : nil
            found = self.old_passwords.any? do |old_password|
              args = case arguments_type
              when :restful_authentication
                [REST_AUTH_SITE_KEY, old_password[:salt], self.password, REST_AUTH_SITE_KEY].compact
              else
                [self.password, old_password[:salt]].compact
              end
              old_password[:password] == crypto_provider.encrypt(args)
            end
            self.errors.add_to_base "New password should be different from the password used last 10 times." if found
          end

          def update_old_passwords
            if self.errors.empty? and send("#{crypted_password_field}_changed?")
              self.old_passwords ||= []
              self.old_passwords.unshift({:password => send("#{crypted_password_field}"), :salt =>  send("#{password_salt_field}") })
              self.old_passwords = self.old_passwords[0, 10]
            end
          end

          base.serialize :old_passwords, Array
          base.after_validation :update_old_passwords

          base.acts_as_authentic do |c|
            c.login_field = 'user_name'
            c.logged_in_timeout = config_options[:trisano_auth][:login_timeout].minutes
            
            
            
            # Perishable token maintenance resets the user's perishable token with every page load.
            # This makes it impossible to use the token for password resets. By disabling
            # we take responsiblity for making sure the user's perishable token is reset once used.
            c.disable_perishable_token_maintenance = true
            c.perishable_token_valid_for = config_options[:trisano_auth][:password_reset_timeout].minutes

            password_length_constraints = c.validates_length_of_password_field_options.reject { |k,v| [:minimum, :maximum].include?(k) }
            c.validates_length_of_password_field_options = password_length_constraints.merge :within => 0..64

            c.validates_format_of :password, :with => /^(?!.*(.)\1)(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[^0-9a-zA-Z])([\x20-\x7E]){7,}$/, :if => :require_password_changed?, :message => "must be at least 7 characters.  It must include a number, a lower case letter, an upper case character, and a non-alphanumeric character.  No two characters may be repeated sequentially."
            c.validate :password_repeated?, :if => :require_password_changed?
            c.validate :current_password?, :if => :require_current_password_changed?
          end


          base.send :include, InstanceMethods

          base.class_eval do

            extend ClassMethods
            attr_accessor :current_password, :current_password_changed

            def current_password=(current_password)
              @current_password_changed = true
              @current_password = current_password
            end
            
            before_create :initialize_tokens
            
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





