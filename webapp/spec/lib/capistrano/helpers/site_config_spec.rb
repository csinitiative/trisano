require 'spec_helper'

module Capistrano::Helpers

  describe "Building a site config for a capistrano deploy" do
    include SiteConfig

    # simulate capistrano setters
    def set symbol, value
      @values[symbol] = value
      self.class.send(:define_method, symbol, lambda { return value })
    end

    def exists? symbol
      @values.key? symbol
    end

    def fetch symbol, default_value=nil
      @values[symbol].nil? ? default_value : @values[symbol]
    end
    
    before do
      @values = {}
    end

    after do
      @values.keys.each { |key| self.class.send(:remove_method, key) }
    end
    
    it "only generates keys for set values" do
      set :bi_server_url, 'some_url'
      generate_site_config.size.should == 1
    end

    it "sets the data warehouse server url" do
      set :bi_server_url, "http://biserver.com/pentaho/Home"
      generate_site_config['bi_server_url'].should == 'http://biserver.com/pentaho/Home'
    end

    it "sets the url for help documentation" do
      set :help_url, "https://wiki.someapp.com/tfm"
      generate_site_config['help_url'].should == 'https://wiki.someapp.com/tfm'
    end

    it "sets user switch availability" do
      set :auth_allow_user_switch, false
      generate_site_config['auth_allow_user_switch'].should be_false
    end

    it "sets whether user switch appears below the footer" do
      set :auth_allow_user_switch_hidden, false
      generate_site_config['auth_allow_user_switch_hidden'].should be_false
    end

    it "sets the google api key" do
      set :google_api_key, 'SOMEKEY'
      generate_site_config['google_api_key'].should == 'SOMEKEY'
    end

    it "sets the google channel" do
      set :google_channel, 'developer'
      generate_site_config['google_channel'].should == 'developer'
    end

    it 'sets the google client id' do
      set :google_client_id, 'ima client'
      generate_site_config['google_client_id'].should == 'ima client'
    end

    it 'sets the default admin id' do
      set :default_admin_id, 'trisano_admin'
      generate_site_config['default_admin_id'].should == 'trisano_admin'
    end
    
    it "sets the receiving faciltiy name for hl7 messages" do
      set :recv_facility, "CSI Dept. of TriSano, Bureau of Informatics^2.16.840.9.886571.2.99.8^ISO"
      generate_site_config['hl7']['recv_facility'].should == "CSI Dept. of TriSano, Bureau of Informatics^2.16.840.9.886571.2.99.8^ISO"
    end

    it "sets the hl7 processing id" do
      set :processing_id, "P^"
      generate_site_config['hl7']['processing_id'].should == 'P^'
    end

    it "doesn't create an hl7 key if none of the values are set" do
      generate_site_config.keys.should_not include('hl7')
    end
    
    it "sets the login timeout" do
      set :login_timeout, 30
      generate_site_config['trisano_auth']['login_timeout'].should == 30
    end

    it "sets the password reset timeout" do
      set :password_reset_timeout, 4320 #3 days
      generate_site_config['trisano_auth']['password_reset_timeout'] = 4320
    end

    %w(phone_number phone_number_format area_code area_code_format use_area_code extension use_country_code country_code country_code_format).each do |var|
      it "sets the telephone #{var} value" do
        set var.to_sym, "#{var} value"
        generate_site_config['telephone'][var].should == "#{var} value"
      end
    end

    it "sets the telephone format for form builder answers" do
      set :form_builder_phone, 'some regex'
      generate_site_config['answer']['phone'].should == 'some regex'
    end
  
    it "turns the locale witching on" do
      set :locale_switching, true
      generate_site_config['locale']['allow_switching'].should == true
    end
  end
end
