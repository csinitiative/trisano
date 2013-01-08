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

class AddIndexes < ActiveRecord::Migration
  def self.up
	execute("DROP INDEX index_participations_on_type;")
	execute("DROP INDEX index_participations_on_event_id;")
	execute("CREATE INDEX part_event_type_created_ix ON participations (event_id, type, created_at);")
	execute("CREATE INDEX entities_id_type_ix ON entities (id, entity_type);")
	execute("DROP INDEX fe_tree_id_index;")
	execute("DROP INDEX fe_parent_id_index;")
	execute("CREATE INDEX formelem_tree_lft_rgt_type_ix ON form_elements (tree_id, lft, rgt, type);")
	execute("CREATE INDEX formelem_type_ix ON form_elements (type);")
	execute("CREATE INDEX formelem_parent_name_ix ON form_elements (parent_id, name);")
	execute("DROP INDEX index_disease_events_on_event_id;")
	execute("CREATE INDEX disev_event_created_ix ON disease_events (event_id, created_at);")
	execute("CREATE INDEX users_uid_ix ON users (uid);")
  end

  def self.down
	execute("DROP INDEX users_uid_ix;")
	execute("DROP INDEX disev_event_created_ix ON disease_events;")
	execute("CREATE INDEX index_disease_events_on_event_id ON disease_events USING btree (event_id);") 
	execute("DROP INDEX formelem_type_ix;")
	execute("DROP INDEX formelem_parent_name_ix;")
	execute("DROP INDEX formelem_tree_lft_rgt_type_ix;")
	execute("CREATE INDEX fe_parent_id_index ON form_elements USING btree (parent_id);")
	execute("CREATE INDEX fe_tree_id_index ON form_elements USING btree (tree_id);")
	execute("DROP INDEX entities_id_type_ix;")
	execute("DROP INDEX part_event_type_created_ix;")
	execute("CREATE INDEX index_participations_on_event_id ON participations USING btree (event_id);")
	execute("CREATE INDEX index_participations_on_type ON participations USING btree (type);")
  end
end
