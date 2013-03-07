class AddAutoAssignFlagToDiseasesForms < ActiveRecord::Migration
  def self.up
    add_column :diseases_forms, :auto_assign, :boolean
    ActiveRecord::Base.transaction do
      execute("ALTER TABLE diseases_forms DROP CONSTRAINT diseases_forms_pkey")
    end
    add_column :diseases_forms, :id, :primary_key
    DiseasesForm.update_all("auto_assign=true")
  end

  def self.down
    remove_column :diseases_forms, :auto_assign
    remove_column :diseases_forms, :id
    ActiveRecord::Base.transaction do
      execute("ALTER TABLE diseases_forms ADD PRIMARY KEY (form_id, disease_id)")
    end
  end
end
