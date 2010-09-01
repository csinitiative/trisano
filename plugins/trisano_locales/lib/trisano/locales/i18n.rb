unless I18n.respond_to? :selectable_locales

  I18n.class_eval do

    class << self

      def selectable_locales
        available_locales.collect do |locale|
          name = backend.instance_eval { lookup(locale, :locale_name) }
          [name, locale] if name
        end.compact
      end

      def default_locale_with_db=(locale)
        if DefaultLocale.update_locale(locale)
          self.default_locale_without_db = locale
        end
      end
      alias_method_chain(:default_locale=, :db)
    end
  end

end

