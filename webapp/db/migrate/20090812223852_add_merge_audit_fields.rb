class AddMergeAuditFields < ActiveRecord::Migration
  def self.up
    add_column :entities, :merged_into_entity_id, :integer
    add_column :entities, :merge_effected_events, :text
  end

  def self.down
    remove_column :entities, :merged_into_entity_id
    remove_column :entities, :merge_effected_events
  end
end
