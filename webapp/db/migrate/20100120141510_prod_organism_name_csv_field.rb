class ProdOrganismNameCsvField < ActiveRecord::Migration
  def self.up
    return unless RAILS_ENV == 'production'
    CsvField.create({
      :sort_order => 25,
      :export_group => 'lab',
      :long_name => 'lab_organism',
      :use_description => 'organism.try(:organism_name)'
    })
  end

  def self.down
  end
end
