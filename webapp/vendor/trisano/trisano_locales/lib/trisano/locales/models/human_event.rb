module Trisano
  module Locales
    module Models
      module HumanEvent
        hook! "HumanEvent"
        reloadable!

        def self.included(base)
          base.extend(ClassMethods)
          base.class_eval do
            class << self
              alias_method_chain :name_and_bdate_select, :translations
              alias_method_chain :name_and_bdate_joins,  :translations
            end
          end
        end

        module ClassMethods
          def name_and_bdate_select_with_translations
            name_and_bdate_select_without_translations.map do |field|
              field.gsub(/external_codes/, 'translated_codes')
            end
          end

          def name_and_bdate_joins_with_translations(options)
            name_and_bdate_joins_without_translations(options).map do |join|
              if join =~ /join external_codes/i
                "LEFT JOIN external_code_translations translated_codes
                   ON (
                       translated_codes.locale = '#{I18n.locale.to_s}' AND
                       translated_codes.external_code_id = people.birth_gender_id
                   )"
              else
                join
              end
            end

          end
        end
      end
    end
  end
end
