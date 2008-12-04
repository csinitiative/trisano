class AddSelfJoinForEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :parent_id, :integer
    add_column :participations, :participating_event_id, :integer
  end

  def self.down
    remove_column :events, :parent_id
    remove_column :participations, :participating_event_id
  end
end
