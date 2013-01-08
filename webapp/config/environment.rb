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
# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require 'thread'
require File.join(File.dirname(__FILE__), 'boot')

# REMOVE WHEN UPGRADING PAST RAILS 2.3.4
if Gem::VERSION >= "1.3.6"
  module Rails
    class GemDependency
      def requirement
        r = super
        (r == Gem::Requirement.default) ? nil : r
      end
    end
  end
end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  config.plugins = [ :rails_inheritable_attributes_manager, :trisano_locales, :all ]
  config.plugin_paths << "#{RAILS_ROOT}/vendor/trisano"

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += %W( #{RAILS_ROOT}/lib/exporters )

  # Change the default locale
  #config.i18n.default_locale = :test

  # Make rails look in nested dirs for locale yml files
  config.i18n.load_path += Dir[File.join(RAILS_ROOT, 'config', 'locales', '**', '*.{rb,yml}')]

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Uncomment the following line for running in Tomcat
  # config.logger = Logger.new(STDOUT)


  # Uncomment the following line if you want to read the log file in Eclipse
  # config.active_record.colorize_logging = false

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session_store = :cookie_store
  config.action_controller.session = {
    :key => '_trisano_session',
    :secret      => 'aec289bfea4950e50e37af2854f59c2a7a96c0a8d24ef218517b08a5790a272ae2b2ee0c2fe5aa18217a599b20b322c5596fd3983a42240aef4ce71a37102d41'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  config.active_record.observers = :core_field_observer

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # Require this here because it needs to be loaded before plugins
  require 'engines/hooks'
  require 'extensible_helpers/module'

  # without this, can't include a gem plugin in explicit plugin load order
  config.gem 'rails_inheritable_attributes_manager'

  # For datetime validation plugin to switch to U.S. format (month/day/year)
  # http://svn.viney.net.nz/things/rails/plugins/validates_date_time/README
  config.after_initialize do
    require 'rails_inheritable_attributes_manager'
    require 'validates_timeliness_formats'
    require "active_record/errors"
    require "active_record/scopes"
    require "active_record/rollback_transactions"
    require "active_record/nested_attributes_helper"
    require "active_record/reflection_ext"
    require "attachment_fu/attachment_fu_validation_patch"
    require "mmwr/mmwr"
    require "blankable"
    require "extend_better_nested_set"
    require 'export/cdc'
    require 'utilities'
    require 'will_paginate'
    require 'core_ext/array'
    require 'core_ext/boolean'
    require 'core_ext/string'
    require 'task_filter'
    require 'event_search'
    require 'fulltext_search'
    require 'name_and_birthdate_search'
    require 'new_human_event_search_results'
    require 'routing/workflow_helper'
    require 'hl7/extensions'
    require 'postgres_fu'
    require 'menu_array'
    require 'i18n_logger'
    require 'i18n_core_field'

    # Use a custom xml parser for handling incoming xml
    ActiveSupport::XmlMini.backend = :NamespaceFilter
  end

end

PG_LOCALE = ENV['PG_LOCALE'] ||= 'en_US'

if RAILS_ENV == "development" || RAILS_ENV == "test" || RAILS_ENV == "uattest"
  TRISANO_UID = ENV['TRISANO_UID'].blank? ? 'default' : ENV['TRISANO_UID']
else
  TRISANO_UID = nil
end
