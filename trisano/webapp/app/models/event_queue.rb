# Copyright (C) 2007, 2008, The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the terms of the
# GNU Affero General Public License as published by the Free Software Foundation, either 
# version 3 of the License, or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
# See the GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License along with TriSano. 
# If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

class EventQueue < ActiveRecord::Base
  belongs_to :jurisdiction, :class_name => 'Entity', :foreign_key => :jurisdiction_id
  validates_presence_of :queue_name, :jurisdiction_id
  before_save :replace_white_space

  class << self
    def queues_for_jurisdictions(jurisdiction_ids)
      jurisdiction_ids = jurisdiction_ids.to_a
      find(:all, :conditions => ["jurisdiction_id IN (?)", jurisdiction_ids])
    end
  end

  private

  def replace_white_space
    self.queue_name = Utilities::make_queue_name(self.queue_name) + "-" + Utilities::make_queue_name(jurisdiction.current_place.short_name)
  end
end
