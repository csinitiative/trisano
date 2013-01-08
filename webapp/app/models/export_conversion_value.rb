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
class ExportConversionValue < ActiveRecord::Base
  belongs_to :export_column

  validates_presence_of :value_to
  validates_numericality_of :sort_order, :allow_blank => true
  validates_uniqueness_of :sort_order, :scope => :export_column_id, :allow_blank => true

  delegate :length_to_output, :to => :export_column
  delegate :data_type, :to => :export_column

  def conversion_type
    safe_call_chain(:export_column, :data_type)
  end

end
