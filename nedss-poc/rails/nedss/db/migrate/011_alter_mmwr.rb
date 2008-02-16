class AlterMmwr < ActiveRecord::Migration
  def self.up
    remove_column :events, :MMWR 
    add_column :events, :MMWR_week, :integer
    add_column :events, :MMWR_year, :integer
  end
  
  def self.down
    add_column :events, :MMWR, :integer
  end
end
