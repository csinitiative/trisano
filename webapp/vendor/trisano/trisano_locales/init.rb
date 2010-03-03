# Include hook code here
I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '**', '*.{rb,yml}')]
require 'trisano_locales'

# now we make sure our database settings are honored
config.to_prepare do
  begin
    if current = DefaultLocale.current
      I18n.default_locale_without_db = current.to_sym
    else
      I18n.default_locale = I18n.default_locale
    end
  rescue
    puts "Cannot load default locale. Rebuilding database?"
  end
end

