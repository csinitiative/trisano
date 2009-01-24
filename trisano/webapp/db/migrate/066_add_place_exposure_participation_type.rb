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

class AddPlaceExposureParticipationType < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
        Code.create(:code_name        => 'participant',
                    :the_code         => 'PE',
                    :code_description => 'Place Exposure',
                    :sort_order       => 65)
    end
  end

  def self.down
    Code.find_by_code_description('Place Exposure').destroy if RAILS_ENV == 'production'
  end
end
