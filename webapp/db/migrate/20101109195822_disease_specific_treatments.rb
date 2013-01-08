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

class DiseaseSpecificTreatments < ActiveRecord::Migration
  def self.up
    transaction do
      execute "ALTER TABLE treatments ADD COLUMN \"default\" boolean;"
      execute "ALTER TABLE treatments ALTER COLUMN \"default\" SET DEFAULT false;"
      execute "UPDATE treatments SET \"default\" = false;"
      execute "ALTER TABLE treatments ALTER COLUMN \"default\" SET NOT NULL;"
    end
  end

  def self.down
    remove_column :treatments, :default
  end
end
