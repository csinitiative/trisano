module Trisano
  module Locales
    module Test
      module Models
        module CsvField
          hook! 'CsvField'
          reloadable!

          def self.included(base)
            base.class_eval do
              extend(ClassMethods)
              class << self
                alias_method_chain :load_csv_fields, :test_translations
              end
            end
          end

          module ClassMethods
            def load_csv_fields_with_test_translations(csv_fields)
              transaction do
                load_csv_fields_without_test_translations(csv_fields)
                load_test_translations
              end
            end

            def load_test_translations
              connection.execute(<<-SQL)
              INSERT INTO csv_field_translations (id, csv_field_id, locale, long_name, short_name, created_at, updated_at)
                SELECT nextval('csv_field_translations_id_seq'), a.id, 'test', 'x' || a.long_name, NULL, now(), now()
                FROM csv_fields a LEFT JOIN csv_field_translations b
                  ON (
                      b.locale = 'test' AND
                      a.id = b.csv_field_id
                  )
                WHERE b.csv_field_id IS NULL;
              SQL
            end
          end

        end
      end
    end
  end
end
