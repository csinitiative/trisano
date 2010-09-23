module Trisano
  module TrisanoPerinatalHepB
    module Models
      module CoreFieldsDisease
        hook! "CoreFieldsDisease"
        reloadable!

        class << self

          def included(base)
            base.extend(ClassMethods)
          end

        end

        module ClassMethods
          def create_perinatal_hep_b_associations
            fields = YAML::load_file(File.join(File.dirname(__FILE__), '../../../../db/defaults/core_fields.yml'))
            self.create_associations('Hepatitis B Pregnancy Event', fields)

            fields = YAML::load_file(File.join(File.dirname(__FILE__), '../../../../db/defaults/core_field_replacements.yml'))
            self.create_associations('Hepatitis B Pregnancy Event', fields)
          end
        end
      end
    end
  end
end
