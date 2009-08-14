class AddCodeUniqueConstraint < ActiveRecord::Migration
  def self.up
    execute 'ALTER TABLE codes ALTER COLUMN code_name SET NOT NULL';
    execute 'ALTER TABLE codes ALTER COLUMN the_code SET NOT NULL';
    execute 'ALTER TABLE external_codes ALTER COLUMN code_name SET NOT NULL';
    execute 'ALTER TABLE external_codes ALTER COLUMN the_code SET NOT NULL';

    add_index :codes, [:code_name, :the_code], :unique => true
    add_index :external_codes, [:code_name, :the_code], :unique => true
  end

  def self.down
    remove_index :codes, [:code_name, :the_code]
    remove_index :external_codes, [:code_name, :the_code]

    execute 'ALTER TABLE codes ALTER COLUMN code_name DROP NOT NULL';
    execute 'ALTER TABLE codes ALTER COLUMN the_code DROP NOT NULL';
    execute 'ALTER TABLE external_codes ALTER COLUMN code_name DROP NOT NULL';
    execute 'ALTER TABLE external_codes ALTER COLUMN the_code DROP NOT NULL';
  end
end
