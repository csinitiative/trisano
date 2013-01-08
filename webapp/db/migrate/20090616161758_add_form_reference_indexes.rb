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

class AddFormReferenceIndexes < ActiveRecord::Migration
  def self.up
    execute("ALTER TABLE form_references ALTER COLUMN template_id SET NOT NULL;")
    execute("CREATE INDEX f_template_id_index ON forms USING btree (template_id)")
    execute("CREATE UNIQUE INDEX index_form_references_on_event_id_and_template_id ON form_references USING btree (event_id, template_id)")
  end

  def self.down
    execute("ALTER TABLE form_references ALTER COLUMN template_id DROP NOT NULL;")
    execute("DROP INDEX f_template_id_index")
    execute("DROP INDEX index_form_references_on_event_id_and_template_id")
  end
end
