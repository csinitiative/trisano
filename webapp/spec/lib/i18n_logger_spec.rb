require File.dirname(__FILE__) + '/../spec_helper'
require 'stringio'

describe I18nLogger do

  before(:all) do
    @log = Logging.appenders.string_io.new("test_log")
    DEFAULT_LOGGER.add_appenders(@log)
  end

  after(:all) do
    DEFAULT_LOGGER.remove_appenders("test_log")
  end

  it "should log debug level" do
    I18nLogger.debug("locale_name").should be_true
    @log.readline.should == "DEBUG  server : locale_name: English\n"
  end

  it "should log info level" do
    I18nLogger.info("locale_name").should be_true
    @log.readline.should == " INFO  server : locale_name: English\n"
  end

  it "should log warn level" do
    I18nLogger.warn("locale_name").should be_true
    @log.readline.should == " WARN  server : locale_name: English\n"
  end

  it "should log error level" do
    I18nLogger.error("locale_name").should be_true
    @log.readline.should == "ERROR  server : locale_name: English\n"
  end

  it "should log fatal level" do
    I18nLogger.fatal("locale_name").should be_true
    @log.readline.should == "FATAL  server : locale_name: English\n"
  end

  it "should log in the default locale" do
    I18n.default_locale = :test
    I18nLogger.debug("locale_name").should be_true
    @log.readline.should == "DEBUG  server : locale_name: Test\n"
    I18n.default_locale = :en
  end

  it "should pass options along to the translate call" do
    I18nLogger.debug("loading_disease_group", :disease_group => "Enterics").should be_true
    @log.readline.should == "DEBUG  server : loading_disease_group: Loading disease group Enterics\n"
  end

end

