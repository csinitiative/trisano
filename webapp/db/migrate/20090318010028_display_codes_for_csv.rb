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

class DisplayCodesForCsv < ActiveRecord::Migration
  def self.up
    add_column  :csv_fields, :use_code,        :string
    add_column  :csv_fields, :use_description, :string
    add_column  :csv_fields, :export_group,    :string
    add_column  :csv_fields, :updated_at,      :timestamp
    add_column  :csv_fields, :created_at,      :timestamp
    remove_column :csv_fields, :short_name_max
    remove_column :csv_fields, :evaluation
    remove_column :csv_fields, :group
  end

  def self.down
    remove_column :csv_fields, :use_code
    remove_column :csv_fields, :use_description
    remove_column :csv_fields, :updated_at
    remove_column :csv_fields, :created_at
    remove_column :csv_fields, :export_group
    add_column  :csv_fields, :short_name_max, :integer
    add_column  :csv_fields, :evaluation,     :string
    add_column  :csv_fields, :group,          :string
  end
end
