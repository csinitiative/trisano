module Capistrano::Helpers
  module SiteConfig

    def update_site_config config
      config = update_base_config config
      config = update_hl7_config  config
      config = update_google_api config
      config = update_telephone_config config
      config = update_locale_config config
      config.delete('inherit') if config['inherit']
      config
    end

    private

    def update_base_config config
      config['bi_server_url'] = bi_server_url if exists? :bi_server_url
      config['help_url'] = help_url if exists? :help_url
      config
    end
    
    def update_hl7_config config
      config['hl7']['recv_facility'] = recv_facility if exists? :recv_facility
      config['hl7']['processing_id'] = processing_id if exists? :processing_id
      config
    end

    def update_google_api config
      config['google_api_key'] = google_api_key if exists? :google_api_key
      config['google_channel'] = google_channel if exists? :google_channel
      config['google_client_id'] = google_client_id if exists? :google_client_id
      config
    end

    def update_telephone_config config
      config['telephone']['phone_number'] = phone_number if exists? :phone_number
      config['telephone']['phone_number_format'] = phone_number_format if exists? :phone_number_format
      config['telephone']['area_code'] = area_code if exists? :area_code
      config['telephone']['area_code_format'] = area_code_format if exists? :area_code_format
      config['telephone']['use_area_code'] = use_area_code if exists? :use_area_code
      config['telephone']['extension'] = extension if exists? :extension
      config['telephone']['country_code'] = country_code if exists? :country_code
      config['telephone']['country_code_format'] = country_code_format if exists? :country_code_format
      config['telephone']['use_country_code'] = use_country_code if exists? :use_country_code
      config['answer']['phone'] = form_builder_phone if exists? :form_builder_phone
      config
    end

    def update_locale_config config
      config['locale']['allow_switching'] = locale_switching if exists? :locale_switching
      config
    end
  end
end
