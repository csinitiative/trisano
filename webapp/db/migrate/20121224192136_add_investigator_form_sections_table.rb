class AddInvestigatorFormSectionsTable < ActiveRecord::Migration
  def self.up
    create_table :investigator_form_sections do |t|
      t.integer :event_id
    end
  end

  def self.down
    drop_table :investigator_form_sections
  end
end
