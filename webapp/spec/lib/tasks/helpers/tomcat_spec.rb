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
  end
end
