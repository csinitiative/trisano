require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do

  it "should return the correct localized path for an error" do
    I18n.locale = :en
    controller.send(:static_error_page_path, 403).should == "#{RAILS_ROOT}/public/403.en.html"
    controller.send(:static_error_page_path, 404).should == "#{RAILS_ROOT}/public/404.en.html"
    controller.send(:static_error_page_path, 422).should == "#{RAILS_ROOT}/public/422.en.html"
    controller.send(:static_error_page_path, 500).should == "#{RAILS_ROOT}/public/500.en.html"
    controller.send(:static_error_page_path, 503).should == "#{RAILS_ROOT}/public/503.en.html"

    I18n.locale = :test
    controller.send(:static_error_page_path, 403).should == "#{RAILS_ROOT}/public/403.test.html"
    controller.send(:static_error_page_path, 404).should == "#{RAILS_ROOT}/public/404.test.html"
    controller.send(:static_error_page_path, 422).should == "#{RAILS_ROOT}/public/422.test.html"
    controller.send(:static_error_page_path, 500).should == "#{RAILS_ROOT}/public/500.test.html"
    controller.send(:static_error_page_path, 503).should == "#{RAILS_ROOT}/public/503.test.html"
  end

  it "should return the default file path for an error if the locale doesn't have a translated error page" do
    I18n.locale = :my_two_year_olds_speak
    controller.send(:static_error_page_path, 403).should == "#{RAILS_ROOT}/public/403.html"
    controller.send(:static_error_page_path, 404).should == "#{RAILS_ROOT}/public/404.html"
    controller.send(:static_error_page_path, 422).should == "#{RAILS_ROOT}/public/422.html"
    controller.send(:static_error_page_path, 500).should == "#{RAILS_ROOT}/public/500.html"
    controller.send(:static_error_page_path, 503).should == "#{RAILS_ROOT}/public/503.html"
  end

  it "should return the default 500 file path for an error that has no error files at all" do
    I18n.locale = :en
    controller.send(:static_error_page_path, 123).should == "#{RAILS_ROOT}/public/500.html"
    controller.send(:static_error_page_path, 342).should == "#{RAILS_ROOT}/public/500.html"
    controller.send(:static_error_page_path, 234).should == "#{RAILS_ROOT}/public/500.html"
  end


end
