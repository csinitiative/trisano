require File.dirname(__FILE__) + '/../../spec_helper'
require 'trisano/deployment'

include Trisano

describe Deployment do
  include DeploymentsSpecHelper

  it "should delete all symlinks in vendor/trisano" do
    pending
    given_plugin_symlink('sample')
    FileUtils.should_receive(:rm).with(plugin_symlink('sample'))
    Deployment.delete_all_plugin_links
  end

  it "should create plugin links based on descriptor" do
    pending
    given_app_deployment('development', {'plugins' => ['something'] } )
    given_plugin('something')
    given_no_plugin_symlink('something')
    FileUtils.should_receive(:ln_sf).with(expanded_plugin_path('something'), plugin_symlink('something'))
    Deployment.new(project_deployment('development')).create_plugin_symlinks
  end

  it "should look for plugins relative to deployment's directory" do
    pending
    given_other_deployment('a_deployment', {'plugins' => ['something'] })
    given_other_project_plugin('something')
    given_no_plugin_symlink('something')
    FileUtils.should_receive(:ln_sf).with(expanded_other_project_plugin_path('something'), plugin_symlink('something'))
    Deployment.new(other_project_deployment('a_deployment')).create_plugin_symlinks
  end
end
