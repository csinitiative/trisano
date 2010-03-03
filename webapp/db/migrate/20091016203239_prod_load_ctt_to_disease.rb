class ProdLoadCttToDisease < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      diseases = YAML.load_file(File.join(RAILS_ROOT, 'db/defaults/diseases.yml'))
      diseases.each do |k, v|
        v.delete :loinc_codes
        v.delete :organisms
      end
      transaction do
        Disease.load_from_yaml diseases.to_yaml
      end
    end
  end

  def self.down
  end
end
