module Trisano
  module Locales
    module Model
      module Person
        hook! "Person"

        def self.included(base)
          base.class_eval do
            extend(ClassMethods)
            class << self
              alias_method_chain :people_search_joins, :translations
            end
          end
        end

        module ClassMethods
          def people_search_joins_with_translations(options)
            joins = people_search_joins_without_translations(options)
            joins.map do |join|
              if join =~ /LEFT JOIN external_codes AS states/i
                "LEFT JOIN external_code_translations AS states ON addresses.state_id = states.external_code_id AND states.locale = '#{I18n.locale.to_s}'"
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
