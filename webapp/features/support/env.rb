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

# Sets up the Rails environment for Cucumber

ENV["RAILS_ENV"] = "feature"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')

gem 'cucumber', '>= 0.6.3'
gem 'cucumber-rails'

#rspec
require 'spec/expectations'
require 'spec/matchers'

require 'cucumber/formatter/unicode' # Comment out this line if you don't want Cucumber Unicode support
require 'cucumber/rails/rspec'
require 'cucumber/rails/world'
require 'cucumber/rails/active_record'
require 'cucumber/web/tableish'

require 'webrat'
require 'webrat/core/matchers'

require 'features/support/xpaths'

require File.expand_path(File.dirname(__FILE__) + '/../../spec/support/matchers/html_matchers')

# Selenium helpers required for all feature runs because shared helpers rely on helper methods like get_random_disease
require File.expand_path(File.dirname(__FILE__) + '/../../spec/uat/trisano_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../spec/uat/trisano_forms_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../spec/uat/trisano_admin_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../spec/uat/trisano_places_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../spec/uat/trisano_contacts_helper')

include TrisanoHelper
include TrisanoFormsHelper
include TrisanoAdminHelper
include TrisanoPlacesHelper
include TrisanoContactsHelper
include Trisano::HTML::Matchers

require 'factory_girl'

# Load up factories
Dir[File.join(File.dirname(__FILE__), '..', '..', '{spec,vendor/trisano/*/spec}', 'factories', '*.rb')].each do |f|
  require File.expand_path(f)
end

# Load up spec helpers
Dir[File.join(File.dirname(__FILE__), '..', '..', '{spec,vendor/trisano/*/spec}', 'support', 'spec_helpers', '*.rb')].each do |f|
  require File.expand_path(f)
  include self.class.const_get(File.basename(f).gsub('.rb','').split("_").map{ |word| word.capitalize }.to_s)
end

require 'factory_girl/step_definitions'

# explicitly load support files
require File.expand_path(File.join(File.dirname(__FILE__), 'trisano'))
require File.expand_path(File.join(File.dirname(__FILE__), 'trisano_form_builder'))

# make path_tos more extensible
Cucumber::Rails::World.class_eval do
  @@extension_path_names = []
end

# If you set this to false, any error raised from within your app will bubble
# up to your step definition and out to cucumber unless you catch it somewhere
# on the way. You can make Rails rescue errors and render error pages on a
# per-scenario basis by tagging a scenario or feature with the @allow-rescue tag.
#
# If you set this to true, Rails will rescue all errors and render error
# pages, more or less in the same way your application would behave in the
# default production environment. It's not recommended to do this for all
# of your scenarios, as this makes it hard to discover errors in your application.
ActionController::Base.allow_rescue = true

# If you set this to true, each scenario will run in a database transaction.
# You can still turn off transactions on a per-scenario basis, simply tagging
# a feature or scenario with the @no-txn tag. If you are using Capybara,
# tagging with @culerity or @javascript will also turn transactions off.
#
# If you set this to false, transactions will be off for all scenarios,
# regardless of whether you use @no-txn or not.
#
# Beware that turning transactions off will leave data in your database
# after each scenario, which can lead to hard-to-debug failures in
# subsequent scenarios. If you do this, we recommend you create a Before
# block that will explicitly put your database in a known state.
#Cucumber::Rails::World.use_transactional_fixtures = true

# How to clean your database when transactions are turned off. See
# http://github.com/bmabey/database_cleaner for more info.
#require 'database_cleaner'
#DatabaseCleaner.strategy = :truncation
