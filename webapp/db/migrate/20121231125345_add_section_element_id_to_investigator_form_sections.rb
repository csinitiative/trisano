class AddSectionElementIdToInvestigatorFormSections < ActiveRecord::Migration
  def self.up
    add_column :investigator_form_sections, :section_element_id, :integer
  end

  def self.down
    drop_column :investigator_form_sections, :section_element_id
  end
end
