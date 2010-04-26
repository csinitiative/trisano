# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

class AddRoleTranslations < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    transaction do
      create_table(:role_translations) do |t|
        t.integer(:role_id, :null => false)
        t.string(:locale, :null => false)
        t.string(:role_name, :limit => 100)
        t.text(:description)
        t.timestamps
      end
      add_foreign_key(:role_translations, :role_id, :roles)
      add_index(:role_translations, [:role_id, :locale], :unique => true)
      execute(<<-SQL)
        INSERT INTO role_translations (id, role_id, locale, role_name, description, created_at, updated_at)
          SELECT nextval('role_translations_id_seq'), id, 'en', role_name, description, now(), now()
          FROM roles;
      SQL
      #remove_column(:roles, :role_name)
      #remove_column(:roles, :description)
    end
  end

  def self.down
    transaction do
      drop_table(:role_translations)
      #add_column(:roles, :role_name, :text)
      #add_column(:roles, :description, :text)
    end
  end
end
