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
require File.dirname(__FILE__) + '/../../spec_helper'
require 'trisano/deployment'

include Trisano

describe Deployment do

  it "should create vendor/trisano, if it doesn't exist" do
    given_no_trisano_plugin_dir
    FileUtils.expects(:mkdir_p).with(vendor_trisano_dir)
    Deployment.prep_plugin_dir
  end

  it "should delete all symlinks in vendor/trisano" do
    given_plugin_symlink('sample')
    FileUtils.expects(:rm).with(plugin_symlink('sample'))
    Deployment.delete_all_plugin_links
  end

  it "should create plugin links based on descriptor" do
    given_app_deployment('development', {'plugins' => ['something'] } )
    given_plugin('something')
    given_no_plugin_symlink('something')
    FileUtils.expects(:ln_sf).with(expanded_plugin_path('something'), plugin_symlink('something'))
    Deployment.new(project_deployment('development')).create_plugin_symlinks
  end

  it "should look for plugins relative to deployment's directory" do
    given_other_deployment('a_deployment', {'plugins' => ['something'] })
    given_other_project_plugin('something')
    given_no_plugin_symlink('something')
    FileUtils.expects(:ln_sf).with(expanded_other_project_plugin_path('something'), plugin_symlink('something'))
    Deployment.new(other_project_deployment('a_deployment')).create_plugin_symlinks
  end

  it "should link installer, if specified in descriptor" do
    given_other_deployment('a_deployment', {'installer' => 'installer'})
    given_other_project_dir('installer')
    given_no_installer_link
    FileUtils.expects(:ln_sf).with(expanded_other_project_path('installer'), installer_symlink)
    Deployment.new(other_project_deployment('a_deployment')).create_installer_symlink
  end

  it "should delete installer symlink, if present" do
    given_installer_symlink
    FileUtils.expects(:rm).with(installer_symlink)
    Deployment.delete_installer_symlink
  end

  it "should link deployer, if specified in descriptor" do
    given_other_deployment('a_deployment', {'cap_deploy' => 'deploy_this'})
    given_other_project_dir('deploy_this')
    given_no_cap_deploy_link
    FileUtils.expects(:ln_sf).with(expanded_other_project_path('deploy_this'), cap_deploy_symlink)
    Deployment.new(other_project_deployment('a_deployment')).create_cap_deploy_symlink
  end

  it "should delete deploy symlink, if present" do
    given_cap_deploy_symlink
    FileUtils.expects(:rm).with(cap_deploy_symlink)
    Deployment.delete_cap_deploy_symlink
  end

  it "should delete ext javascript dir, if present" do
    File.expects(:exists?).with(Deployment.ext_javascripts).returns(true)
    FileUtils.expects(:rm_rf).with(Deployment.ext_javascripts)
    Deployment.delete_ext_javascripts
  end

  it "should delete ext images dir, if present" do
    File.expects(:exists?).with(Deployment.ext_images).returns(true)
    FileUtils.expects(:rm_rf).with(Deployment.ext_images)
    Deployment.delete_ext_images
  end

  it "should create ext javascript directory, if not present" do
    given_no_ext_javascript_dir
    FileUtils.expects(:mkdir_p).with(Deployment.ext_javascripts)
    Deployment.prep_ext_javascripts
  end

  it "should create ext images directory, if not present" do
    given_no_ext_images_dir
    FileUtils.expects(:mkdir_p).with(Deployment.ext_images)
    Deployment.prep_ext_images
  end

  it "should link plugin javascript dirs into ext javascripts dir" do
    given_other_deployment('a_deployment', {'plugins' => ['foo'] })
    given_other_project_plugin('foo')
    given_other_project_plugin_js('foo')
    given_ext_javascript_dir
    File.expects(:exists?).with(Deployment.ext_javascript('foo')).returns(false)
    FileUtils.expects(:ln_sf).with(expanded_other_project_plugin_js_path('foo'), File.join(Deployment.ext_javascripts, 'foo'))
    Deployment.new(other_project_deployment('a_deployment')).create_javascript_links
  end

  it "should link plugin image dirs into ext images dir" do
    given_other_deployment('a_deployment', {'plugins' => ['foo'] })
    given_other_project_plugin('foo')
    given_other_project_plugin_images('foo')
    given_ext_images_dir
    File.expects(:exists?).with(Deployment.ext_image('foo')).returns(false)
    FileUtils.expects(:ln_sf).with(expanded_other_project_plugin_image_path('foo'), File.join(Deployment.ext_images, 'foo'))
    Deployment.new(other_project_deployment('a_deployment')).create_image_links
  end
end
