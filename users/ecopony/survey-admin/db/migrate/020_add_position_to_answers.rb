class AddPositionToAnswers < ActiveRecord::Migration
  def self.up
    add_column :answers, :position, :integer
  end

  def self.down
    remove_column :answers, :position
  end
end
