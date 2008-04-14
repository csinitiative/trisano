class AddProgramIdToDiseases < ActiveRecord::Migration
  def self.up
    add_column :diseases, :program_id, :integer
  end

  def self.down
    remove_column :diseases, :program_id
  end
end
