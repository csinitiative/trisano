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
require 'fileutils'
require 'yaml'
require 'delegate'

module Trisano
  class Deployment

    class << self
      def use_deployment(deployment)
        delete_all_plugin_links
        delete_installer_symlink
        delete_cap_deploy_symlink
        delete_ext_javascripts
        delete_ext_images
        prep_plugin_dir
        d = new(deployment)
        d.create_plugin_symlinks
        d.create_installer_symlink
        d.create_cap_deploy_symlink
        d.create_javascript_links
        d.create_image_links
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

      def delete_cap_deploy_symlink
        if File.exists?(trisano_cap_deploy_path) && File.symlink?(trisano_cap_deploy_path)
          FileUtils.rm(trisano_cap_deploy_path)
        end
      end

      def delete_ext_javascripts
        recursive_delete(ext_javascripts)
      end

      def delete_ext_images
        recursive_delete(ext_images)
      end

      def recursive_delete(path)
        FileUtils.rm_rf(path) if File.exists?(path)
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

      def ext_javascripts
        File.join(public_app_path, 'javascripts', 'ext')
      end

      def ext_images
        File.join(public_app_path, 'images', 'ext')
      end

      def public_app_path
        File.join(app_path, 'webapp', 'public')
      end

      def ext_javascript(name)
        File.join(ext_javascripts, name)
      end

      def ext_image(name)
        File.join(ext_images, name)
      end

      def trisano_installer
        File.expand_path(File.join(app_path, 'install'))
      end

      def trisano_cap_deploy_path
        File.expand_path(File.join(app_path, 'webapp', 'config', 'deploy'))
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

      def prep_ext_javascripts
        prep_ext(ext_javascripts)
      end

      def prep_ext_images
        prep_ext(ext_images)
      end

      def prep_ext(path)
        unless File.exists?(path)
          FileUtils.mkdir_p(path)
        end
      end
    end

    def initialize(deployment)
      @deployment = deployment
      @class_delegator = SimpleDelegator.new(self.class)
    end

    def create_plugin_symlinks
      plugins.each do |plugin|
        unless File.exists?(trisano_extension(plugin.name))
          FileUtils.ln_sf(plugin.plugin_path, trisano_extension(plugin.name))
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

    def create_cap_deploy_symlink
      if descriptor['cap_deploy']
        unless File.exists?(trisano_cap_deploy_path)
          FileUtils.ln_sf(cap_deploy(descriptor['cap_deploy']), trisano_cap_deploy_path)
        end
      end      
    end

    def create_javascript_links
      plugins.each do |plugin|
        unless File.exists?(ext_javascript(plugin.name))
          prep_ext_javascripts
          FileUtils.ln_sf(plugin.javascripts, ext_javascript(plugin.name)) if plugin.javascripts?
        end
      end
    end

    def create_image_links
      plugins.each do |plugin|
        unless File.exists?(ext_image(plugin.name))
          prep_ext_images
          FileUtils.ln_sf(plugin.images, ext_image(plugin.name)) if plugin.images?
        end
      end
    end

    def plugins
      return @plugins if @plugins
      @plugins = (descriptor['plugins'] || []).map do |name|
        Plugin.new(name, self)
      end
    end

    def installer(name)
      Installer.new(name, self).installer_path
    end

    def cap_deploy(name)
      CapDeploy.new(name, self).cap_deploy_path
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

      attr_reader :name

      def initialize(plugin_name, deployment)
        @name = plugin_name
        @deployment = deployment
      end

      def plugin_path
        @plugin_path ||= plugin_paths.each do |path|
          return path if File.exists?(path)
        end
        raise "Plugin not found: #@plugin was not in #{plugin_paths.join(',')}"
      end

      def javascripts?
        File.exists?(javascripts)
      end

      def images?
        File.exists?(images)
      end

      def javascripts
        File.join(plugin_public_path, 'javascripts')
      end

      def images
        File.join(plugin_public_path, 'images')
      end

      def plugin_public_path
        File.join(plugin_path, 'public')
      end

      def plugin_paths
        [:base_path, :app_path].map do |p|
          File.join(@deployment.send(p), 'plugins', name)
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

    class CapDeploy
      def initialize(path, deployment)
        @cap_deploy_path = path
        @deployment = deployment
      end

      def cap_deploy_path
        path = File.join(@deployment.base_path, @cap_deploy_path)
        return path if File.exists?(path)
        raise "Could not find cap deploy directory at #{path}"
      end
    end
  end
end
