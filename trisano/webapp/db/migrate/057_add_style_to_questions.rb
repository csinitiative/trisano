class AddStyleToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :style, :string
  end

  def self.down
    remove_column :questions, :style
  end
end
