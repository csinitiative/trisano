class DropCodeNameDescritptions < ActiveRecord::Migration
  def self.up
    remove_column :code_names, :description
  end

  def self.down
    add_column :code_names, :description, :text
  end
end
