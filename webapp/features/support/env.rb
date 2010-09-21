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

# Sets up the Rails environment for Cucumber

ENV["RAILS_ENV"] = "test"
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
