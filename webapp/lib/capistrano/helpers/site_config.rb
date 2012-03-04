module Capistrano::Helpers
  module SiteConfig

    def generate_site_config
      config = external_resources_config
      config = config.merge auth_config
      config = config.merge hl7_config
      config = config.merge google_api_config
      config = config.merge telephone_config
      config = config.merge locale_config
      config = config.merge mailer_config
      config = config.merge redis_config
      config.each { |key, value| config.delete(key) if value.nil? }
      config
    end

    private

    def redis_config
      config = {}
      config['redis_server'] = safe_fetch :redis_server
      config
    end

    def external_resources_config
      config = {}
      config['bi_server_url'] = safe_fetch :bi_server_url
      config['support_url'] = safe_fetch :support_url
      config['help_url'] = safe_fetch :help_url
      config
    end

    def auth_config
      config = {}
      config['default_admin_uid'] = fetch :default_admin_uid, 'trisano_admin'
      config['auth_allow_user_switch'] = safe_fetch :user_switching
      config['auth_allow_user_switch_hidden'] = safe_fetch :auth_allow_user_switch_hidden
      config['auth_src_header'] = safe_fetch :auth_src_header
      config['default_admin_id'] = safe_fetch :default_admin_id
      trisano_auth = {}
      trisano_auth['login_timeout'] = safe_fetch :auth_login_timeout
      trisano_auth['password_reset_timeout'] = safe_fetch :password_reset_timeout
      config['trisano_auth'] = trisano_auth unless trisano_auth.values.all?(&:nil?)
      config
    end

    def hl7_config
      hl7_config = {}
      hl7_config['recv_facility'] = safe_fetch :recv_facility
      hl7_config['processing_id'] = safe_fetch :processing_id
      hl7_config.values.all?(&:nil?) ? {} : { 'hl7' => hl7_config }
    end

    def google_api_config
      config = {}
      config['google_api_key']   = safe_fetch :google_api_key
      config['google_channel']   = safe_fetch :google_channel
      config['google_client_id'] = safe_fetch :google_client_id
      config
    end

    def telephone_config
      telephone_config = {}
      telephone_config['phone_number'] = safe_fetch :phone_number
      telephone_config['phone_number_format'] = safe_fetch :phone_number_format
      telephone_config['area_code'] = safe_fetch :area_code
      telephone_config['area_code_format'] = safe_fetch :area_code_format
      telephone_config['use_area_code'] = safe_fetch :use_area_code
      telephone_config['extension'] = safe_fetch :extension
      telephone_config['country_code'] = safe_fetch :country_code
      telephone_config['country_code_format'] = safe_fetch :country_code_format
      telephone_config['use_country_code'] = safe_fetch :use_country_code
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

    def mailer_config
      mailer_host = safe_fetch(:mailer_host) || 'localhost'

      config = {}
      mailer_config = {}
      mailer_config['address'] = safe_fetch :mailer_address
      mailer_config['port'] = safe_fetch :mailer_port
      mailer_config['domain'] = safe_fetch :mailer_domain
      mailer_config['user_name'] = safe_fetch :mailer_user_name
      mailer_config['password'] = safe_fetch :mailer_password
      mailer_config['authentication'] = safe_fetch :mailer_authentication
      mailer_config['enable_starttls_auto'] = safe_fetch :mailer_enable_starttls_auto
      mailer_config.reject! { |k, v| v.nil? }
      config[(safe_fetch(:mailer) || 'smtp')] = mailer_config

      (mailer_config.empty?) ? {} : { 'host' => mailer_host, 'mailer' => config }
    end

    # shortcut for: value if exists? :value
    def safe_fetch symbol
      fetch symbol if exists? symbol
    end
  end
end
