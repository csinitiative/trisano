# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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
role :app, "vagrant"
role :web, "vagrant"
role :db,  "vagrant", :primary => true
set :port, 2222

## configure the database.yml
set :database, 'trisano_production'
set :username, 'trisano_user'
set :database_password, 'password'
set :database_host, 'localhost'

## site config settings
set :bi_server_url , "http://localhost:18080/pentaho/Home"
set :help_url      , "https://wiki.csinitiative.com/display/tri30/Help"

## google api support
# set :google_api_key, 'ABQIAAAAo4YnME-vPXWNSkpYMt_0oxSVimV7G6dhrQkR9OVUux8Cu6qgXBQnOd8sgchiXpy5cIzq5sf8Ufz4LQ'
# set :gooele_channel, 'developer'

##  hl7 configuration
# set :recv_facility, "CSI Dept. of TriSano, Bureau of Informatics^2.16.840.9.886571.2.99.8^ISO"
# set :processing_id, "P^"

## User auth configurations
# set :auth_login_timeout, 30
# set :password_reset_timeout, 60 * 24 * 3
set :default_admin_uid, 'trisano_admin'
set :user_switching, false
set :auth_src_header, 'TRISANO_UID'

## Telephone configuration
set :phone_number, "^(\d{3})-?(\d{4})$"
set :phone_number_format, "%s-%s"
set :area_code, "^(\d{3})$"
set :area_code_format, "(%s)"
set :use_area_code, true
set :extension, "^(\d{1,6})$"

# Customize to include country codes
# use_country_code: true
# country_code: "^(\d{1,3})$"
# country_code_format: "+%s"

# Configure the format of a phone number in custom forms created in formbuilder
set :form_builder_phone, "^\d{3}-\d{3}-\d{4}$"

## Locale configuration
set :locale_switching, false

## Set mailer behavior
set :mailer, :smtp => {
  :address => 'localhost',
  :port => 587,
  :user_name => 'joe@localhost',
  :password => 'password',
  :enable_starttls_auto => true
}

