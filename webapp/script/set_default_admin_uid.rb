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

@default_admin_uid = config_option(:default_admin_uid)
@default_admin_password = config_option(:default_admin_password)
@auth_src_env = config_option(:auth_src_env)
@auth_allow_user_switch = config_option(:auth_allow_user_switch)

puts "Setting default administrator UID to #{@default_admin_uid}"

if User.new.respond_to?(:crypted_password) && RAILS_ENV=="development"
  
  raise "ERROR: You must not specify the auth_env_src option in site_config while using the trisano_auth plugin" if @auth_src_env.present?
  raise "ERROR: You must not enable the auth_allow_user_switch option in site_config while using the trisano_auth plugin" if @auth_allow_user_switch == true

  if @default_admin_password.present?
    puts "Setting default administrator password to #{@default_admin_password}"
    puts "WARNING: PLESAE CHANGE DEFAULT PASSWORDS!"
    
    RoleMembership.transaction do
      User.set_default_admin_uid_with_auth(@default_admin_uid, :password => @default_admin_password, :password_confirmation => @default_admin_password)
    end

  else
    raise "ERROR: You must specify the default_admin_password in the site config while using the trisano_auth plugin" 
  end

else

  RoleMembership.transaction do
      User.set_default_admin_uid(@default_admin_uid)
  end

end
