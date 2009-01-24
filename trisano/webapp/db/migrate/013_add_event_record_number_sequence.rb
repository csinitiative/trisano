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

class AddEventRecordNumberSequence < ActiveRecord::Migration
  
  def self.up
    execute "CREATE SEQUENCE events_record_number_seq INCREMENT 1 START 2008000001 MINVALUE 2008000001 MAXVALUE 2008999999 CACHE 1;"
  end
  
  def self.down
   execute "DROP SEQUENCE events_record_number_seq;" 
  end
  
end
