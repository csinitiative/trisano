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

module Export
  module Cdc
       
    def check_cdc_updates      
      self.cdc_update = cdc_attributes_changed?(old_attributes)
    end

    private

    def cdc_attributes_changed?(old_attributes)
      return false unless old_attributes
      
      cdc_fields = %w(first_reported_PH_date udoh_case_status_id)
      old_attributes.select {|k, v| cdc_fields.include?(k)}.reject do |field, value|
        $stdout.puts "#{field}:#{value}:#{self.attributes[field]}"
        self.attributes[field] == value
      end.size > 0
    end

  end
end



