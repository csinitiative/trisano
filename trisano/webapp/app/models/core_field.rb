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

class CoreField < ActiveRecord::Base
  
  after_save :flush_caches
  
  class << self
    
    def find_event_fields_for(event_type, *args)
      return [] if event_type.blank?
      with_scope(:find => {:conditions => ["event_type=?", event_type]}) do
        find(*args)
      end
    end

    # uses the memoization cache 
    def event_fields(event_type)
      event_fields_hash[event_type] ||= find_event_fields_for(event_type, :all).inject({}) do |hash, field|
        hash[field.key] = field.attributes.symbolize_keys
        hash[field.key][:model] = field
        hash
      end
    end

    def flush_memoization_cache
      @event_fields_hash = nil
    end

    private 

    def event_fields_hash
      @event_fields_hash ||= {}
    end
  end

  def flush_caches
    CoreField.flush_memoization_cache
  end
end
