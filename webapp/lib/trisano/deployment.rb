require 'fileutils'
require 'yaml'
require 'delegate'

module Trisano
  class Deployment

    class << self
      def use_deployment(deployment)
        delete_all_plugin_links
        delete_installer_symlink
        prep_plugin_dir
        d = new(deployment)
        d.create_plugin_symlinks
        d.create_installer_symlink
      end

      def delete_all_plugin_links
        Dir[trisano_extensions].each do |ext|
          FileUtils.rm(ext) if File.symlink?(ext)
        end
      end

      def delete_installer_symlink
        if File.exists?(trisano_installer) && File.symlink?(trisano_installer)
          FileUtils.rm(trisano_installer)
        end
      end

      def trisano_extensions
        File.join(trisano_ext_path, '*')
      end

      def trisano_extension(plugin_name)
        File.join(trisano_ext_path, plugin_name)
      end

      def trisano_ext_path
        File.join(app_path, 'webapp', 'vendor', 'trisano')
      end

      def trisano_installer
        File.expand_path(File.join(app_path, 'install'))
      end

      def app_path
        File.expand_path(
          File.join(
            File.dirname(__FILE__), '..', '..', '..'))
      end

      def prep_plugin_dir
        unless File.exists?(trisano_ext_path)
          FileUtils.mkdir_p(trisano_ext_path)
        end
      end
    end

    def initialize(deployment)
      @deployment = deployment
      @class_delegator = SimpleDelegator.new(self.class)
    end

    def create_plugin_symlinks
      plugins.each do |plugin_name|
        unless File.exists?(trisano_extension(plugin_name))
          FileUtils.ln_sf(plugin(plugin_name), trisano_extension(plugin_name))
        end
      end
    end

    def create_installer_symlink
      if descriptor['installer']
        unless File.exists?(trisano_installer)
          FileUtils.ln_sf(installer(descriptor['installer']), trisano_installer)
        end
      end
    end

    def plugins
      @plugins ||= descriptor['plugins']
    end

    def plugin(plugin_name)
      Plugin.new(plugin_name, self).plugin_path
    end

    def installer(name)
      Installer.new(name, self).installer_path
    end

    def descriptor
      return @descriptor if @descriptor
      @descriptor = YAML.load(IO.read(descriptor_path))
    end

    def base_path
      File.expand_path(File.join(deployment_path, '..', '..'))
    end

    def deployment_path
      File.expand_path(@deployment)
    end

    def descriptor_path
      File.join(deployment_path, 'descriptor.yml')
    end

    def method_missing(symbol, *args)
      @class_delegator.send(symbol, *args)
    end

    class Plugin
      def initialize(plugin_name, deployment)
        @plugin_name = plugin_name
        @deployment = deployment
      end

      def plugin_path
        plugin_paths.each do |path|
          return path if File.exists?(path)
        end
        raise "Plugin not found: #@plugin was not in #{plugin_paths.join(',')}"
      end

      def plugin_paths
        [:base_path, :app_path].map do |p|
          File.join(@deployment.send(p), 'plugins', @plugin_name)
        end.uniq
      end
    end

    class Installer
      def initialize(name, deployment)
        @installer_name = name
        @deployment = deployment
      end

      def installer_path
        path = File.join(@deployment.base_path, @installer_name)
        return path if File.exists?(path)
        raise "Could not find installer at #{path}"
      end
    end
  end
end
