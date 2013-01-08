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
class AddSpecimenExportConversionValues < ActiveRecord::Migration
  def self.up
    c = ExportColumn.find_by_export_column_name("SPECIMEN SITE")
    if c
      ExportConversionValue.find_or_create_by_export_column_id_and_value_from_and_value_to_and_sort_order(c.id, "Blood/Serum", "13", 13)
      ExportConversionValue.find_or_create_by_export_column_id_and_value_from_and_value_to_and_sort_order(c.id, "Cerebrospinal fluid (CSF)", "14", 14)
    end
  end

  def self.down
    c = ExportColumn.find_by_export_column_name("SPECIMEN SITE")
    if c
      v = ExportConversionValue.find_by_export_column_id_and_value_from_and_value_to_and_sort_order(c.id, "Blood/Serum", "13", 13)
      v.delete if v

      v = ExportConversionValue.find_by_export_column_id_and_value_from_and_value_to_and_sort_order(c.id, "Cerebrospinal fluid (CSF)", "14", 14)
      v.delete if v
    end
  end
end
