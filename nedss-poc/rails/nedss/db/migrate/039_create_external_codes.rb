class CreateExternalCodes < ActiveRecord::Migration
  def self.up
      create_table :external_codes, :force => true do |t|
          t.string :code_name, :limit => 50
          t.string :the_code, :limit => 20
	  t.string :code_description, :limit => 100
	  t.integer :sort_order
	  t.integer :next_ver
	  t.integer :previous_ver
	  t.boolean :live, :default => TRUE
	  t.timestamps
      end
  end

  def self.down
      drop_table :external_codes

  end
end
