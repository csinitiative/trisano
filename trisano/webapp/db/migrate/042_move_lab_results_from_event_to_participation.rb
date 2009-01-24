# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

class MoveLabResultsFromEventToParticipation < ActiveRecord::Migration

  def self.up 
    remove_column :lab_results, :event_id 
    add_column    :lab_results, :participation_id, :integer

    execute "ALTER TABLE lab_results
             ADD CONSTRAINT fk_participation FOREIGN KEY (participation_id) REFERENCES participations(id)" 
  end

  def self.down
    execute "ALTER TABLE lab_results
             DROP CONSTRAINT fk_participation" 

    remove_column :lab_results, :participation_id 
    add_column    :lab_results, :event_id, :integer

    execute "ALTER TABLE lab_results
             ADD CONSTRAINT fk_event FOREIGN KEY (event_id) REFERENCES events(id)" 
  end

end 
