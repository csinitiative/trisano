class AddTypeColumnToEventTable < ActiveRecord::Migration
  def self.up

    ActiveRecord::Base.transaction do
      add_column :events, :type, :string
      execute("UPDATE events SET type = 'MorbidityEvent'")
    end

  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :events, :type
    end
  end
end
