module Trisano
  module Locales
    module Models
      module TranslatedCsvField
        hook! CsvField
        reloadable!

        def self.included(base)
          base.class_eval do
            translate :long_name, :short_name
          end
        end

      end
    end
  end
end
