# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

class AddPrimaryKeysToIntersectionTables < ActiveRecord::Migration

  def self.up
    ActiveRecord::Base.transaction do

      say "Adding primary keys to intersection tables"
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
