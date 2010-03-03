module Trisano
  module Locales
    module UrlHelpers
      module FormTagWrapper

        class << self
          def included(base)
            base.class_eval do
              alias_method_chain :form_tag_html, :locale
            end
          end
        end

        # wrapping form tag html in the same was as button_to
        def form_tag_html_with_locale(html_options)
          returning "" do |result|
            result << form_tag_html_without_locale(html_options)
            unless params[:locale].blank?
              if html_options["method"] == 'get'
                result << hidden_field_tag(:locale, params[:locale])
              end
            end
          end
        end

      end
    end
  end
end

ActionView::Helpers::FormTagHelper.send :include, Trisano::Locales::UrlHelpers::FormTagWrapper
