require 'spec_helper'

module Trisano
  describe Application do
    include Trisano

   after :each do
     reload_site_config
   end

    it "returns a human readable version number" do
      application.version_number.should == Trisano::VERSION.join('.')
    end

    it "returns a subscription space based on the version number, if site is a subscriber" do
      application.subscriber = true
      application.subscription_space.should == "tri" + Trisano::VERSION[0,2].join
    end

    it "returns the open -ce flavor of subscription space for nonsubscribers" do
      application.subscriber = false
      application.subscription_space.should == "tri"
    end

    it "has help available if the application is a subscriber" do
      application.subscriber = true
      SITE_CONFIG['base']['help_url'] = nil
      application.should have_help
    end

    it "has help available if a custom help url is configured" do
      application.subscriber = false
      SITE_CONFIG['base']['help_url'] = 'http://help.me'
      application.should have_help
    end

    it "does not have help if its not a subscriber and does have a help url configured" do
      application.subscriber = false
      SITE_CONFIG['base']['help_url'] = nil
      application.should_not have_help
    end
  end
end
