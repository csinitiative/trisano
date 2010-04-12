# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

class CodeName < ActiveRecord::Base

  has_many :codes, :foreign_key => :code_name, :primary_key => :code_name
  has_many :external_codes, :foreign_key => :code_name, :primary_key => :code_name

  validates_presence_of :code_name
  validates_length_of :code_name, :maximum => 50
  validates_uniqueness_of :code_name

  def self.loinc_scale
    self.find_by_code_name('loinc_scale')
  end

  def description
    I18n.t(code_name, :scope => [:code_names])
  end
end
