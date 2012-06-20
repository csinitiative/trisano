class CreateEventTypeTransition < ActiveRecord::Migration
  def self.up
    create_table :event_type_transitions do |t|
      t.string :was
      t.string :became
      t.references :user
      t.references :event
      t.timestamps
    end

  end

  def self.down
    drop_table :event_type_transitions
  end
end
