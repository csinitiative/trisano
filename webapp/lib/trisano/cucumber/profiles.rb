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
require File.join(File.dirname(__FILE__), 'profile_loader')

module Trisano
  module Cucumber

    class Profiles

      class << self
        def load_profiles
          profiles = new
          profiles.merge!(load_base_profiles)
          plugin_cuke_pattern = File.join(File.dirname(__FILE__), '../../../vendor/trisano/*/cucumber.yml')
          Dir.glob(plugin_cuke_pattern).each do |f|
            f = File.expand_path(f)
            profiles.merge!(load_profiles_from(f))
          end
          profiles
        end

        def load_base_profiles
          file = File.join(File.dirname(__FILE__), 'cucumber.yml')
          load_profiles_from(file)
        end

        def load_profiles_from(file)
          ProfileLoader.new(file).profiles
        end
      end

      def merge!(hash)
        hash.keys.each do |key|
          merge_value!(key, hash[key])
        end
      end

      def [](name)
        profiles_hash[name]
      end

      def each(&block)
        profiles_hash.each do |k,v|
          yield k,v
        end
      end 

      def count
        profiles_hash.count
      end

      def to_yaml
        profiles_hash.to_yaml
      end

      def profiles_hash
        @profiles_hash ||= {}
      end

      def merge_value!(key, value)
        return if value.nil? || value.size == 0
        if profiles_hash[key]
          profiles_hash[key] << " " + value
        else
          profiles_hash[key] = value
        end
      end
    end

  end
end
