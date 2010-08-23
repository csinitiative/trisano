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

  class << self

    # take advantage of the AR request cache and get all the codes in one go
    def drop_down_selections(code_name, event=nil)
      code_group = drop_down_code_name(code_name)
      return [] unless code_group
      if code_group.external
        selections = ExternalCode.selections_for_event(event)
      else
        selections = Code.active.exclude_jurisdiction
      end
      selections.select { |code| code.code_name == code_name }
    end

    # take advantage of the AR request cache and get all the code names in one go
    def drop_down_code_name(name)
      find(:all, :select => 'code_name, external').select do |code_group|
        code_group.code_name == name
      end.first
    end

    def loinc_scale
      self.find_by_code_name('loinc_scale')
    end

  end

  def description
    I18n.t(code_name, :scope => [:code_names])
  end
end
