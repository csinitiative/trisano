require 'spec_helper'
require 'tasks/helpers'

module Tasks::Helpers
  describe Tomcat do
        
    before do
      @tomcat = Tomcat.new
    end

    it "creates a tomcat:start task" do
      ::Rake::Task['tomcat:start'].should_not be_nil
    end

    it "creates a :stop task" do
      ::Rake::Task['tomcat:stop'].should_not be_nil
    end

    it ":start task raises an error is startup script is missing" do
      Tomcat.new :tomcat_home => 'i/do/not/exist/'
      lambda { ::Rake::Task['tomcat:start'].invoke }.should raise_error
    end

    it ":stop task raised an error is shutdown script is missing" do
      Tomcat.new :tomcat_home => 'i/do/not/exist/'
      lambda { ::Rake::Task['tomcat:stop'].invoke }.should raise_error
    end
 
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

  end
end
