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

class Privilege < ActiveRecord::Base
  
  has_many :entitlements
  has_many :users, :through => :entitlements
  
  has_many :privileges_roles
  has_many :roles, :through => :privileges_roles

  class << self
    def investigate_event
      find_by_priv_name('investigate_event')
    end

    def update_event
      find_by_priv_name('update_event')
    end
  end
end
