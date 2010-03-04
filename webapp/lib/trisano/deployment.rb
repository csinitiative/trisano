require 'fileutils'
require 'yaml'
require 'delegate'

module Trisano
  class Deployment

    class << self
      def delete_plugin_links
        Dir[trisano_extensions].each do |ext|
          FileUtils.rm(ext) if File.symlink?(ext)
        end
      end

      def trisano_extensions
        File.join(trisano_ext_dir, '*')
      end

      def trisano_extension(plugin_name)
        File.join(trisano_ext_dir, plugin_name)
      end

      def trisano_ext_dir
        File.join(app_dir, 'webapp', 'vendor', 'trisano')
      end

      def app_dir
        File.expand_path(
          File.join(
            File.dirname(__FILE__), '..', '..', '..'))
      end

      def plugin(plugin_name)
        File.join(plugin_dir, plugin_name)
      end

      def plugin_dir
        File.join(app_dir, 'plugins')
      end

      def deployments
        File.join(app_dir, 'deployments')
      end

    end

    def initialize(deployment)
      @deployment = deployment
      @class_delegator = SimpleDelegator.new(self.class)
    end

    def link_plugins
      plugins.each do |plugin_name|
        unless File.exists?(trisano_extension(plugin_name))
          FileUtils.ln_sf(plugin(plugin_name), trisano_extension(plugin_name))
        end
      end
    end

    def plugins
      @plugins ||= descriptor['plugins']
    end

    def descriptor
      return @descriptor if @descriptor
      f = File.join(deployments, @deployment, 'descriptor.yml')
      @descriptor = YAML.load_file(f)
    end

    def method_missing(symbol, *args)
      @class_delegator.send(symbol, *args)
    end

  end
end
