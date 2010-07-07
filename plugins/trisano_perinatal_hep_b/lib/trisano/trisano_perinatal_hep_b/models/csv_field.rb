module Trisano
  module TrisanoPerinatalHepB
    module Models
      module CsvField
        hook! "CsvField"
        reloadable!

        class << self
          def included(base)
            base.extend(ClassMethods)
          end
        end

        module ClassMethods
          def create_perinatal_hep_b_associations
            fields = YAML::load_file(File.join(File.dirname(__FILE__), '../../../../config/misc/en_csv_fields.yml')).values
            fields.each do |field|
              core_field = CoreField.find_by_key(field["core_field_key"])
              raise "Could not find core field for #{field["core_field_key"]}." if core_field.nil?
              csv_field = self.find_by_long_name(field["long_name"])
              raise "Could not find CSV field for #{field["long_name"]}." if csv_field.nil?
              csv_field.update_attributes!(:core_field_id => core_field.id, :disease_specific => true)
            end
          end
        end
      end
    end
  end
end
