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
