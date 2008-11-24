class ProductionListeriaFormFix < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      transaction do
        execute("UPDATE forms SET status = 'Archived' WHERE id = 310")
        execute("UPDATE forms SET status = 'Archived', version = 6 WHERE id = 315")
        execute("UPDATE forms SET status = 'Archived', version = 7 WHERE id = 316")
        execute("UPDATE forms SET status = 'Archived', version = 8 WHERE id = 317")
        execute("UPDATE forms SET version = 9 WHERE id = 318")
      end
    end
  end

  def self.down
  end
end
