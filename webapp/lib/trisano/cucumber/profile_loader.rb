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

require 'java' if defined?(JRUBY_VERSION)
gem 'cucumber', '>= 0.6.3'
require 'cucumber/cli/profile_loader'
require 'cucumber/cli/configuration'

module Trisano
  module Cucumber

    class ProfileLoader < ::Cucumber::Cli::ProfileLoader
      include ::Cucumber::Cli

      def initialize(cucumber_file = nil)
        @cucumber_yml = nil
        @cucumber_file = cucumber_file
      end

      def profiles
        cucumber_yml.dup
      end

    end

  end
end
