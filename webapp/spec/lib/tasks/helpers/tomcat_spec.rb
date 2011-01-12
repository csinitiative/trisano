require 'spec_helper'
require 'tasks/helpers'

module Tasks::Helpers
  describe Tomcat do
        
    context "home" do
      it "can be set in the options hash" do
        tomcat = Tomcat.new :tomcat_home => '/fake/path'
        tomcat.home.should == '/fake/path'
      end

      it "can be set by the environment var TOMCAT_HOME" do
        ENV['TOMCAT_HOME'] = '/fake/path'
        Tomcat.new.home.should == '/fake/path'
      end
    end

    context "webapp_dir" do
      before do
        @tomcat = Tomcat.new :tomcat_home => '/fake/path'
      end
      
      it "points at the directory where war files are deployed" do
        @tomcat.webapp_dir.should == '/fake/path/webapp'
      end
    end

    context "#stop_tomcat" do
      before do
        @tomcat = Tomcat.new :tomcat_home => '/fake/path'
      end

      it "fails immediately if the shutdown.sh script cannot be found" do
        lambda { @tomcat.stop_server }.should raise_error
      end
    end
  end
end
