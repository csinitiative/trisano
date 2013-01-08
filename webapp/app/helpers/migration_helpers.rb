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

#migration_helpers.rb
module MigrationHelpers

  def add_foreign_key(from_table, from_column, to_table)
    constraint_name = "fk_#{from_column}"

    execute %{alter table #{from_table}
              add constraint #{constraint_name}
              foreign key (#{from_column})
              references #{to_table}(id) MATCH SIMPLE
              ON UPDATE NO ACTION ON DELETE NO ACTION}
  end


  def remove_foreign_key(from_table, from_column)
    constraint_name = "fk_#{from_column}"

    execute %{alter table #{from_table}
              drop constraint #{constraint_name}}
  end

end
