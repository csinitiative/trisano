require File.dirname(__FILE__) + '/../../spec_helper'
require 'trisano/deployment'

include Trisano

describe Deployment do
  include DeploymentsSpecHelper

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

  it "should delete installer symlink, it present" do
    given_installer_symlink
    FileUtils.expects(:rm).with(installer_symlink)
    Deployment.delete_installer_symlink
  end

end
