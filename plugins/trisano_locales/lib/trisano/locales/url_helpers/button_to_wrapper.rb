module Trisano
  module Locales
    module UrlHelpers
      module ButtonToWrapper

        class << self
          def included(base)
            base.class_eval do
              unless defined?(:button_to_without_locale)
                alias_method_chain :button_to, :locale
              end
            end
          end
        end

        # wrapping button_to to support i18n localization better
        def button_to_with_locale(name, options={}, html_options={})
          method = html_options.stringify_keys["method"]
          button_to_without_locale(name, options, html_options).sub("</div></form>") do |match|
            returning "" do |result|
              unless  params[:locale].blank?
                if method && method.to_s == 'get'
                  result << hidden_field_tag(:locale, params[:locale])
                end
              end
              result << match
            end
          end
        end

      end
    end
  end
end

ActionView::Helpers::UrlHelper.send :include, Trisano::Locales::UrlHelpers::ButtonToWrapper
