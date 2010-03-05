I18n.class_eval do

  class << self

    def selectable_locales
      available_locales.collect do |locale|
        name = backend.instance_eval { lookup(locale, :locale_name) }
        [name, locale] if name
      end.compact
    end

    def default_locale_with_db=(locale)
      begin
        dl = DefaultLocale.current || DefaultLocale.new
        unless dl.update_locale(locale)
          dl.logger.error(dl.errors.full_messages.join("\n"))
        end
      rescue
        # possible rebuilding database, so some other fail
        default_locale_without_db = locale
      end
    end
    alias_method(:default_locale_without_db=, :default_locale=)
    alias_method(:default_locale=, :default_locale_with_db=)
  end

end

