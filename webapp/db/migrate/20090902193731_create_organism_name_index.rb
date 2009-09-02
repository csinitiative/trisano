class CreateOrganismNameIndex < ActiveRecord::Migration
  def self.up
    execute "CREATE UNIQUE INDEX index_organisms_on_organism_name ON organisms (LOWER(organism_name));"
  end

  def self.down
    remove_index(:organisms, :organism_name)
  end
end
