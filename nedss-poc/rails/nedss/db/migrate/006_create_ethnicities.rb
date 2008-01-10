class CreateEthnicities < ActiveRecord::Migration
  def self.up
    create_table :ethnicities do |t|
      t.string :ethnic_group, :limit => 30
    end
  end

  def self.down
    drop_table :ethnicities
  end
end
