class DiseasesOrganism < ActiveRecord::Base
  belongs_to :disease
  belongs_to :organism

  validates_uniqueness_of :organism_id, :scope => :disease_id

  class << self

    def load_from_yaml(str_yaml)
      assoc = YAML.load str_yaml
      assoc.each do |key, value|
        value[:organisms].each do |organism_attr|
          organism = Organism.find(:first, :conditions => ['lower(organism_name) = ?', organism_attr[:organism_name].downcase]) || Organism.create(organism_attr)
          value[:diseases].each do |disease_attr|
            disease = Disease.first(:conditions => disease_attr)
            logger.debug " #{disease_attr.inspect}"
            organism.diseases << disease unless organism.diseases.include?(disease)
          end
          organism.save!
        end
      end
    end

  end
end
