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

class Disease < ActiveRecord::Base
  validates_presence_of :disease_name

  has_and_belongs_to_many :external_codes

  class << self

    def find_active(*args)
      with_scope(:find => {:conditions => ['active = ?', true]}) do
        find(*args)
      end
    end

    def disease_status_where_clause
      diseases = []
      find(:all).each do |disease|
        diseases << disease.case_status_where_clause
      end
      "(#{diseases.join(' OR ')})" unless diseases.compact!.empty?
    end      
        
  end

  def case_status_where_clause
    codes = []
    external_codes.each do |code|
      codes << "udoh_case_status_id = '#{code.id}'"
    end
    "(disease_id='#{self.id}' AND (#{codes.join(' OR ')}))" unless codes.empty?
  end
    

end
