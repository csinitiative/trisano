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

class LoincCode < ActiveRecord::Base
  validates_uniqueness_of :loinc_code
  validates_length_of     :loinc_code, :in => 1..10
  validates_length_of     :test_name,  :in => 1..255, :allow_nil => true

  belongs_to :common_test_name
  has_many   :disease_common_test_names, :foreign_key => :common_test_name_id, :primary_key => :common_test_name_id
  has_many   :diseases, :through => :disease_common_test_names
end
