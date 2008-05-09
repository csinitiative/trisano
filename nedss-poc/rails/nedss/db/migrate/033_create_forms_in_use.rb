class CreateFormsInUse < ActiveRecord::Migration

  def self.up
    create_table :form_references do |t|
      t.integer :event_id
      t.integer :form_id
    end
  end

  def self.down
    drop_table :form_references
  end

end
