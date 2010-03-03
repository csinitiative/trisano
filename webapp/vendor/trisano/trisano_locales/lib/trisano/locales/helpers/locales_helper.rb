module Trisano
  module Locales
    module Helpers
      module LocalesHelper
        hook! ActionView::Base
        reloadable!

        def selectable_locales
          I18n.selectable_locales.sort_by(&:first)
        end

        def locale_options(selected_locale = I18n.locale)
          options_for_select(selectable_locales, selected_locale)
        end

        def locale_select_tag(options={})
          select_tag("locale", locale_options,
                     options.merge({:onchange => "this.form.submit()"}))
        end

        def locale_label_tag(options={})
          styles = 'display: inline; color: #FFF; font-size: 10px; font-weight: normal;'
          label_tag('locale', ct('language'),
                    options.merge({:style => styles}))
        end

        def default_locale_tools
          returning "" do |result|
            result << link_to_unless_current(t(:show), default_locale_path)
            result << "&nbsp;|&nbsp;"
            result << link_to_unless_current(t(:edit), edit_default_locale_path)
          end
        end

      end
    end
  end
end
