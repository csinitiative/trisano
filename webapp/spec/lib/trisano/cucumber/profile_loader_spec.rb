require File.dirname(__FILE__) + '/../../../spec_helper'
require 'trisano/cucumber/profile_loader'

include Trisano::Cucumber

describe ProfileLoader do

  before :all do
    @default_cuke_yml = File.join(RAILS_ROOT, 'lib', 'trisano', 'cucumber', 'cucumber.yml')
  end

  it "should load profiles from anywhere we tell it to" do
    loader = ProfileLoader.new(@default_cuke_yml)
    loader.has_profile?('standard').should be_true
  end

  it "should provide access to loaded profiles" do
    loader = ProfileLoader.new(@default_cuke_yml)
    loader.profiles.map{|k,v| k }.sort.should == ['any_standard', 'enhanced', 'standard']
  end

end

