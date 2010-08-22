# Include hook code here
I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '**', '*.{rb,yml}')]
require 'trisano_locales'

# now we make sure our database settings are honored
config.to_prepare do
  DefaultLocale.update_from_db
end

