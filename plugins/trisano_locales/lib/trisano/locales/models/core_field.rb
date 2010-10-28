module Trisano
  module Locales
    module Models
      module CoreField
        hook! "CoreField"
        reloadable!

        def self.included(base)
          base.class_eval do
            extend(ClassMethods)
            class << self
              alias_method_chain(:find_event_fields_for, :translations)
            end
            after_save(:store_translations)
            has_many(:core_field_translations) do
              def for_locale(locale)
                proxy_owner.core_field_translations.select do |t|
                  t.locale == locale
                end.first
              end
            end
            default_scope :include => :core_field_translations
          end
        end

        module ClassMethods
          # optimize this call for grabbing translations
          def find_event_fields_for_with_translations(event_type, *args)
            options = args.extract_options!
            options[:include] ||= :core_field_translations
            args << options
            find_event_fields_for_without_translations(event_type, *args)
          end
        end

        def help_text=(value)
          help_text_assignments[I18n.locale.to_s] = value
        end

        def help_text
          unless text = help_text_assignments[I18n.locale.to_s]
            core_field_translations.for_locale(I18n.locale.to_s).try(:help_text)
          else
            text
          end
        end

        def reload(options={})
          super
          help_text_assignments.clear
        end

        private

        def help_text_assignments
          @help_text_assignments ||= {}
        end

        def store_translations
          help_text_assignments.each do |k, v|
            if locale = core_field_translations.for_locale(k)
              locale.update_attributes!(:help_text => v)
            else
              core_field_translations.build(:locale => k, :help_text => v).save!
            end
          end
          help_text_assignments.clear
        end

      end
    end
  end
end
