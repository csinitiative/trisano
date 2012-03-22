module Trisano
  module TrisanoPerinatalHepB
    module Models
      module DiseaseSpecificSelection
        hook! "DiseaseSpecificSelection"
        reloadable!

        class << self
          def included(base)
            base.extend(ClassMethods)
          end
        end

        module ClassMethods
          def create_perinatal_hep_b_associations
            transaction do
              hep_b_selections.map do |disease_name, batches|
                disease = Disease.find_by_disease_name(disease_name)
                batches['external_codes'].map do |code_hashes|
                  create_selection!(disease, code_hashes)
                end
              end.flatten
            end
          end

          private

          def hep_b_selections
            YAML::load_file(File.dirname(__FILE__) + '/../../../../db/defaults/disease_specific_selections.yml')
          end

          def create_selection!(disease, attributes)
            render = attributes.delete('rendered')
            code = ::ExternalCode.find(:first, :conditions => attributes)
            puts "unable to find code with #{attributes.inspect}" if code.nil?
            create!(:disease => disease, :external_code => code, :rendered => render)
          end
        end

      end
    end
  end
end
