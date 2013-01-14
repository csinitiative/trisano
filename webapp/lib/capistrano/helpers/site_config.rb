# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
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
      config = config.merge cdc_config
      config = config.merge form_builder_config
      config = config.merge session_secret_config
      config.each { |key, value| config.delete(key) if value.nil? }
      config
    end

    private

    def session_secret_config
      config = {}
      config['session_secret_token'] = safe_fetch :session_secret_token
      config
    end

    def form_builder_config
      config = {}
      config['answer'] = { 'phone' => form_builder_phone } if exists? :form_builder_phone
      config['answer'] = { 'numeric' => form_builder_numeric } if exists? :form_builder_numeric
      config
    end

    def cdc_config
      config = {}
      config['cdc_state'] = safe_fetch :cdc_state
      config
    end

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
      trisano_auth['password_expiry_date'] = safe_fetch :password_expiry_date
      trisano_auth['password_expiry_notice_date'] = safe_fetch :password_expiry_notice_date
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
