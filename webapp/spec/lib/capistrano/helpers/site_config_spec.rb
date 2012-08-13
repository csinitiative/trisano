require File.dirname(__FILE__) + '/../../../spec_helper'

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

    def fetch symbol, *args
      value = @values[symbol]
      if value.nil?
        raise "#{symbol} does not exist" if args.empty?
        value = args.first.respond_to?(:call) ? args.first.call : args.first
      end
      value
    end

    before do
      @values = {}
    end

    after do
      @values.keys.each { |key| self.class.send(:remove_method, key) }
    end

    it "only generates default values, when nothing is set" do
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
      set :user_switching, true
      generate_site_config['auth_allow_user_switch'].should be_true
    end

    it "sets whether user switch appears below the footer" do
      set :auth_allow_user_switch_hidden, false
      generate_site_config['auth_allow_user_switch_hidden'].should be_false
    end

    it "sets the authentication header for site minder integration" do
      set :auth_src_header, 'TRISANO_UID'
      generate_site_config['auth_src_header'].should == 'TRISANO_UID'
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
      set :auth_login_timeout, 30
      generate_site_config['trisano_auth']['login_timeout'].should == 30
    end

    it "sets the password reset timeout" do
      set :password_reset_timeout, 4320 #3 days
      generate_site_config['trisano_auth']['password_reset_timeout'] = 4320
    end

    it "sets the password expiry date" do
      set :password_expiry_date, 90 #90 days
      generate_site_config['trisano_auth']['password_expiry_date'] = 90
    end

    it "sets the password expiry notice date" do
      set :password_expiry_notice_date, 14 #14 days
      generate_site_config['trisano_auth']['password_expiry_notice_date'] = 14
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

    it "sets the default admin uid" do
      set :default_admin_uid, 'dave'
      generate_site_config['default_admin_uid'].should == 'dave'
    end

    it "defaults the default_admin uid to trisano_admin" do
      generate_site_config['default_admin_uid'].should == 'trisano_admin'
    end

    it "sets the smtp mailer options" do
      set :mailer                      , "smtp"
      set :mailer_host                 , 'test-host'
      set :mailer_address              , 'test-address'
      set :mailer_port                 , 90210
      set :mailer_domain               , 'test-domain'
      set :mailer_user_name            , 'test-username'
      set :mailer_password             , 'test-password'
      set :mailer_authentication       , 'test-auth'
      set :mailer_enable_starttls_auto , true

      generate_site_config['host'].should == 'test-host'
      generate_site_config['mailer']['smtp']['address'].should == 'test-address'
      generate_site_config['mailer']['smtp']['port'].should == 90210
      generate_site_config['mailer']['smtp']['domain'].should == 'test-domain'
      generate_site_config['mailer']['smtp']['user_name'].should == 'test-username'
      generate_site_config['mailer']['smtp']['password'].should == 'test-password'
      generate_site_config['mailer']['smtp']['authentication'].should == 'test-auth'
      generate_site_config['mailer']['smtp']['enable_starttls_auto'].should == true
    end
  end
end
