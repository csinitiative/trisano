module Trisano
  module Locales
    module Models
      module TranslatedCode
        hook! Code
        hook! ExternalCode
        reloadable!

        def self.included(base)
          base.class_eval do
            translate :code_description, :relation => :code_translations
          end
        end
      end
    end
  end
end
