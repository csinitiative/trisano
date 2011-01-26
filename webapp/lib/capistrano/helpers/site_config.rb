module Capistrano::Helpers
  module SiteConfig

    def generate_site_config
      config = external_resources_config
      config = config.merge auth_config
      config = config.merge hl7_config
      config = config.merge google_api_config
      config = config.merge telephone_config
      config = config.merge locale_config
      config.each { |key, value| config.delete(key) if value.nil? }
      config
    end

    private

    def external_resources_config
      config = {}
      config['bi_server_url'] = fetch :bi_server_url
      config['help_url'] = fetch :help_url
      config
    end
    
    def auth_config
      config = {}
      config['auth_allow_user_switch'] = fetch :auth_allow_user_switch
      config['auth_allow_user_switch_hidden'] = fetch :auth_allow_user_switch_hidden
      config['default_admin_id'] = fetch :default_admin_id
      trisano_auth = {}
      trisano_auth['login_timeout'] = fetch :login_timeout
      trisano_auth['password_reset_timeout'] = fetch :password_reset_timeout
      config['trisano_auth'] = trisano_auth unless trisano_auth.values.all?(&:nil?)
      config
    end

    def hl7_config 
      hl7_config = {}
      hl7_config['recv_facility'] = fetch :recv_facility
      hl7_config['processing_id'] = fetch :processing_id
      hl7_config.values.all?(&:nil?) ? {} : { 'hl7' => hl7_config }
    end

    def google_api_config
      config = {}
      config['google_api_key']   = fetch :google_api_key
      config['google_channel']   = fetch :google_channel
      config['google_client_id'] = fetch :google_client_id
      config
    end

    def telephone_config
      telephone_config = {}
      telephone_config['phone_number'] = fetch :phone_number
      telephone_config['phone_number_format'] = fetch :phone_number_format
      telephone_config['area_code'] = fetch :area_code
      telephone_config['area_code_format'] = fetch :area_code_format
      telephone_config['use_area_code'] = fetch :use_area_code
      telephone_config['extension'] = fetch :extension
      telephone_config['country_code'] = fetch :country_code
      telephone_config['country_code_format'] = fetch :country_code_format
      telephone_config['use_country_code'] = fetch :use_country_code
      config = {}
      config['telephone'] = telephone_config unless telephone_config.each do |k, v|
        telephone_config.delete(k) if v.nil?
      end.empty?
      config['answer'] = { 'phone' => form_builder_phone } if exists? :form_builder_phone
      config
    end

    def locale_config
      config = {}
      config['allow_switching'] = locale_switching if exists? :locale_switching
      config.empty? ? {} : { 'locale' => config }
    end
  end
end
