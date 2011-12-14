class UniqueLiveFormTemplate < ActiveRecord::Migration
  def self.up
    execute "CREATE UNIQUE INDEX unique_live_form_template ON forms (template_id) WHERE status = 'Live'"
  end

  def self.down
    execute 'DROP INDEX unique_live_form_template'
  end
end
