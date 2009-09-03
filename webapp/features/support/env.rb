# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

#rspec
require 'spec/expectations'
require 'spec/matchers'

require 'cucumber/rails/rspec'
require 'cucumber/rails/world'
require 'cucumber/formatter/unicode' # Comment out this line if you don't want Cucumber Unicode support

require 'webrat/core/matchers'
require 'webrat'
require 'cucumber/webrat/element_locator'

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

# Load up factories
Dir.glob(File.join(File.dirname(__FILE__), '..', '..', 'spec', 'factories', '*.rb')) {|f| require f}

# explicitly load support files
require File.join(File.dirname(__FILE__), 'trisano')
require File.join(File.dirname(__FILE__), 'trisano_form_builder')
require File.join(File.dirname(__FILE__), 'hl7_messages')
