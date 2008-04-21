class CreateFormStatuses < ActiveRecord::Migration
  def self.up
    create_table :form_statuses do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :form_statuses
  end
end
