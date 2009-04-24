class AddPrimaryKeysToIntersectionTables < ActiveRecord::Migration

  def self.up
    ActiveRecord::Base.transaction do

      say "Adding primary keys to intersection tables"
      execute("ALTER TABLE places_types ADD PRIMARY KEY (place_id, type_id)")
      execute("ALTER TABLE diseases_forms ADD PRIMARY KEY (form_id, disease_id)")
      execute("ALTER TABLE diseases_external_codes ADD PRIMARY KEY (disease_id, external_code_id)")
      execute("ALTER TABLE diseases_export_columns ADD PRIMARY KEY (disease_id, export_column_id)")
      execute("ALTER TABLE people_races ADD PRIMARY KEY (race_id, entity_id)")
      execute("ALTER TABLE schema_migrations ADD PRIMARY KEY (version)")

      say "Dropping previous unique constraints on schema_migrations and diseases_forms"
      execute("DROP INDEX unique_schema_migrations")
      execute("DROP INDEX index_diseases_forms_on_form_id_and_disease_id")

    end
  end

  def self.down
    ActiveRecord::Base.transaction do

      say "Removing primary keys from some intersection tables"
      execute("ALTER TABLE places_types DROP PRIMARY KEY (place_id, type_id)")
      execute("ALTER TABLE diseases_forms DROP PRIMARY KEY (form_id, disease_id)")
      execute("ALTER TABLE diseases_external_codes DROP PRIMARY KEY (disease_id, external_code_id)")
      execute("ALTER TABLE diseases_export_columns DROP PRIMARY KEY (disease_id, export_column_id)")
      execute("ALTER TABLE people_races DROP PRIMARY KEY (race_id, entity_id)")
      execute("ALTER TABLE schema_migrations DROP PRIMARY KEY (version)")

      say "Adding unique constraints on schema_migrations and diseases_forms"
      execute("CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version)")
      execute("CREATE UNIQUE INDEX index_diseases_forms_on_form_id_and_disease_id ON diseases_forms USING btree (form_id, disease_id)")

    end
  end

end
