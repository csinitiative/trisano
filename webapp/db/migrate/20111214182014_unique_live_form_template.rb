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
class UniqueLiveFormTemplate < ActiveRecord::Migration
  def self.up
    execute %{
        UPDATE forms
            SET status = 'Inactive'
        FROM (
            SELECT DISTINCT ON (template_id) template_id, id
            FROM forms
            WHERE
                status = 'Live' AND
                template_id IN (
                    SELECT template_id
                    FROM (
                        SELECT template_id, count(*)
                        FROM forms
                        WHERE status = 'Live'
                        GROUP BY template_id
                        HAVING count(*) > 1
                    ) foo
                )
            ORDER BY template_id, version DESC
        ) bar
        WHERE
            bar.template_id = forms.template_id AND 
            bar.id != forms.id AND
            forms.status = 'Live'
        RETURNING forms.id;
    }
    execute "CREATE UNIQUE INDEX unique_live_form_template ON forms (template_id) WHERE status = 'Live'"
  end

  def self.down
    execute 'DROP INDEX unique_live_form_template'
  end
end
