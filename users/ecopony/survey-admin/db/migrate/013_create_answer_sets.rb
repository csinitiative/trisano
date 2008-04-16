class CreateAnswerSets < ActiveRecord::Migration
  def self.up
    create_table :answer_sets do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :answer_sets
  end
end
