module Trisano
  module Locales
    module TranslateFields

      def self.included(base)
        base.class_eval do
          extend(BaseMethods)
        end
      end

      module BaseMethods
        # Note: only call once
        def translate(*fields)
          options = fields.extract_options!
          self.translation_relationship = options[:relation]
          self.translated_fields = fields
          extend_base!
        end

        def translation_relationship
          @translation_relationship ||= "#{table_name.chop}_translations".to_sym
        end

        def translation_relationship=(relationship_name)
          @translation_relationship = relationship_name
        end

        def translated_fields
          @translated_fields
        end

        def translated_fields=(fields)
          @translated_fields = fields.collect(&:to_sym)
        end

        def extend_base!
          extend(ClassMethods)
          include(InstanceMethods)
          after_save :update_translations
          has_many(
            translation_relationship,
            :dependent => :delete_all,
            :extend => AssociationExtensions,
            :class_name => "#{self.name}Translation")
        end
      end

      module AssociationExtensions
        def for_locale(locale)
          fk_id = proxy_owner.class.name.underscore + "_id"
          attr = {:locale => locale.to_s, fk_id => proxy_owner.id}
          find(:first, :conditions => attr)
        end
      end

      module InstanceMethods
        def locale
          I18n.locale
        end

        def update_translations
          return true unless connection.table_exists?(self.class.translation_table_name)
          relationship = self.class.translation_relationship
          translation = send(relationship).for_locale(locale)
          translation ||= send(relationship).build(:locale => locale.to_s)
          self.class.translated_fields.each do |field|
            translation.send("#{field.to_s}=", send(field))
          end
          unless translation.save
            translation.errors.full_messages.each do |msg|
              self.errors.add_to_base(msg)
            end
            return false
          end
          true
        end
      end

      module ClassMethods
        def construct_finder_sql(options)
          return super unless connection.table_exists?(translation_table_name)
          make_select_explicit!(options)
          join_translations!(options)
          make_translation_explicit(super)
        end

        def construct_finder_sql_with_included_associations(options, join_dependency)
          use_translated_field_values(super)
        end

        def find_with_associations(options = {})
          options[:include] = merge_includes(options[:include], translation_relationship)
          options[:conditions] = merge_conditions(options[:conditions], {translation_table_name => { :locale => I18n.locale.to_s }})
          super(options)
        end

        def translation_table_name
          "#{table_name.chop}_translations"
        end

        def make_select_explicit!(options)
          columns = case options[:select]
                    when nil, '*': column_names
                    else options[:select].split(',').map(&:strip)
                    end
          options[:select] = columns.collect do |c|
            if c =~ /\./i
              c
            elsif translated_fields.include?(c.to_sym)
              "#{translation_table_name}.#{c}"
            else
              "#{table_name}.#{c}"
            end
          end.join(',').untaint
        end

        def join_translations!(options)
          options[:joins] ||= []
          options[:joins] << "\nLEFT JOIN #{translation_table_name} ON #{table_name}.id = #{translation_table_name}.#{table_name.chop}_id AND '#{I18n.locale.to_s}' = #{translation_table_name}.locale".untaint
        end

        def make_translation_explicit(sql)
          return unless sql
          returning sql do |result|
            translated_fields.each do |field|
              result.gsub!(/([ |,|(])(#{field.to_s})\b/i) { "#{$1}#{translation_table_name}.#{field.to_s}" }
            end
          end
        end

        private

        def use_translated_field_values(sql)
          result = sql
          translated_fields.each do |translated_field|
            result = use_translated_field_value(result, translated_field)
          end
          result
        end

        def use_translated_field_value(sql, field)
          sql.gsub(original_field_regex(field), translated_field_replacement(field))
        end

        def original_field_regex(field)
          /"#{table_name}"\."#{field}"/
        end

        def translated_field_replacement(field)
          %Q("#{translation_table_name}"."#{field}")
        end
      end
    end
  end
end

module ActiveRecord
  class Base
    include Trisano::Locales::TranslateFields
  end
end
