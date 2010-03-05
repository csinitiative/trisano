require File.dirname(__FILE__) + '/../../spec_helper'
require 'trisano/deployment'

include Trisano

describe Deployment do

  def given_plugin_symlink(file)
    Dir.should_receive(:[]).with(Deployment.trisano_extensions).and_return([file])
    File.should_receive(:symlink?).with(file).and_return(true)
  end

  def given_no_plugin_symlink(file)
    File.should_receive(:exists?).with(file).and_return(false)
  end

  def given_deployment(deployment, options = {})
    IO.should_receive(:read).with(Deployment.descriptor_path(deployment)).and_return(options.to_yaml)
  end

  it "should delete all symlinks in vendor/trisano" do
    file = File.expand_path(RAILS_ROOT + "/vendor/trisano/sample")
    given_plugin_symlink(file)
    FileUtils.should_receive(:rm).with(file)
    Deployment.delete_all_plugin_links
  end

  it "should create plugin links based on descriptor" do
    plugin = File.expand_path(RAILS_ROOT + "/../plugins/something")
    symlink = RAILS_ROOT + "/vendor/trisano/something"
    given_deployment('development', {'plugins' => ['something'] } )
    given_no_plugin_symlink(symlink)
    FileUtils.should_receive(:ln_sf).with(plugin, symlink)
    Deployment.new("development").create_plugin_symlinks
  end
end
