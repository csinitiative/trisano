I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '**', '*.{rb,yml}')]
require 'trisano_locales_test'
