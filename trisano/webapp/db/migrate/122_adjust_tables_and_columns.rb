# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

class AdjustTablesAndColumns < ActiveRecord::Migration

  def self.up
    change_column :participations_risk_factors, :risk_factors, :string, :limit => 255
    change_column :participations_risk_factors, :risk_factors_notes, :text
    change_column :roles, :description, :string, :limit => 255

    drop_table :laboratories
    drop_table :organizations
    drop_table :cases_events
  end

  def self.down
    change_column :diseases, :disease_name, :limit => 100
    change_column :participations_risk_factors, :risk_factors, :limit => 25
    change_column :participations_risk_factors, :risk_factors_notes, :limit => 100
    change_column :roles, :description, :limit => 60

    # Not restoring the dropped tables as we never used them
  end
end
