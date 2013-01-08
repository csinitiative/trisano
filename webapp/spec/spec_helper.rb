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
# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

require 'spec/autorun'
require 'spec/rails'
require 'spec/custom_matchers'
require 'nokogiri'
require 'validates_timeliness/matcher'
require 'factory_girl'

def self.trisano_auth?
  User.column_names.include?("crypted_password")
end

if trisano_auth?
  require 'authlogic/test_case'
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each do |f|
  require File.expand_path(f)
end

# Load up factories
Dir[File.join(File.dirname(__FILE__), '..', '{spec,vendor/trisano/*/spec}', 'factories', '*.rb')].each do |f|
  require File.expand_path(f)
end

# Include all the spec helper methods
Dir[File.join(File.dirname(__FILE__), 'support', 'spec_helpers', '*.rb')].each do |f|
  include self.class.const_get(File.basename(f).gsub('.rb','').split("_").map{ |word| word.capitalize }.to_s)
end

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  config.include(CustomMatchers)
  config.include(Trisano::HTML::Matchers)

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  config.global_fixtures = :codes, :external_codes
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner

  config.after(:each) {
    User.current_user = nil
  }
end

def destroy_fixture_data
  CoreFieldTranslation.delete_all
  CsvField.delete_all
  CoreFieldsDisease.delete_all
  CoreField.delete_all
  DiseaseSpecificCallback.delete_all
  DiseaseEvent.delete_all
  ActiveRecord::Base.connection.execute("DELETE FROM diseases_export_columns")
  Disease.delete_all
  ExportConversionValue.delete_all
  ExportColumn.delete_all
  LoincCode.delete_all
  HospitalsParticipation.delete_all
  ParticipationsRiskFactor.delete_all
  Participation.delete_all
  Event.delete_all
  RoleMembership.delete_all
  PrivilegesRole.delete_all
  Person.delete_all
  PersonEntity.delete_all
  Place.delete_all
  PlaceEntity.delete_all
  ActiveRecord::Base.connection.execute("DELETE FROM places_types;")
  Treatment.delete_all
  Code.delete_all
end

require File.join(File.dirname(__FILE__), 'rails_ext') unless ActiveRecord::Base.respond_to? :_find_by_sql_with_capture

# now look for trisano plugin spec helpers and require them
Dir[File.join(RAILS_ROOT, 'vendor', 'trisano', '*', 'spec', 'spec_helpers', '*.rb')].each do |f|
  require f
  include self.class.const_get(File.basename(f).gsub('.rb','').split("_").map {|word| word.capitalize }.to_s)
end

I18n.load_path << File.join(File.dirname(__FILE__), 'fixtures', 'files', 'test_translations.yml')
I18n.reload!
