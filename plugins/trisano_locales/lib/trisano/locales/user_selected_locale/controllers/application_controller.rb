module Trisano
  module Locales
    module UserSelectedLocale
      module Controllers
        module ApplicationController
          hook! "ApplicationController"
          reloadable!

          class << self
            def included(base)
              base.class_eval do
                before_filter :set_locale
                helper_method :allow_locale_switching?
                alias_method_chain :default_url_options, :locale
              end

              # hackity hackity hackity
              # https://rails.lighthouseapp.com/projects/8994/tickets/22-default_url_options-is-being-ignored-by-named-route-optimisation
              base.helper_method :default_url_options
            end
          end

          protected

          def set_locale
            if valid_locale?(params[:locale]) && allow_locale_switching?
              I18n.locale = params[:locale].to_sym
            else
              I18n.locale = I18n.default_locale
            end
          end

          def default_url_options_with_locale(options={})
            returning default_url_options_without_locale(options) do |result|
              if !in_default_locale? and allow_locale_switching?
                result.merge!(:locale => I18n.locale)
              end
            end
          end

          def allow_locale_switching?
            if locale_options = config_options[:locale]
              locale_options[:allow_switching]
            end
          end

          def in_default_locale?
            I18n.locale == I18n.default_locale
          end

          def valid_locale?(locale)
            !locale.blank? && I18n.available_locales.include?(locale.to_sym)
          end
        end
      end
    end
  end
end

