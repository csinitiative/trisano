module Trisano
  module Locales
    module Models
      module EventSearch
        hook! "Event"

        def self.included(base)
          base.class_eval do
            extend(ClassMethods)
            class << self
              alias_method_chain :event_search_joins, :translations
            end
          end
        end

        module ClassMethods
          def event_search_joins_with_translations(options)
            replacement_join = ExternalCode.construct_finder_sql(
              :select => 'id, code_description')
            event_search_joins_without_translations(options).map do |join|
              join.gsub('JOIN external_codes', "JOIN (#{replacement_join}) AS ")
            end
          end
        end

      end
    end
  end
end
