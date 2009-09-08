class AddCodeNamesToCoreFields < ActiveRecord::Migration
  def self.up
    add_column :core_fields, :code_name_id, :integer    
  end
  
  def self.down
    remove_column :core_fields, :code_name_id
  end
end
