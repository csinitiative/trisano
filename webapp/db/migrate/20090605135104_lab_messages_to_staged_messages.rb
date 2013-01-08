# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

class LabMessagesToStagedMessages < ActiveRecord::Migration
  def self.up
    # Though the lab_messages table is already in production, the ELR functionality is not baked.
    # Therefore, this table should be unused and safe to trash.
    drop_table :lab_messages

    create_table :staged_messages do |t|
      t.string :hl7_message, :limit => 10485760, :null => false
      t.string :state, :null => false
      t.string :message_type
      t.text :note
      t.timestamps
    end
  end

  def self.down
    drop_table :staged_messages

    create_table :lab_messages do |t|
      t.string :hl7_message, :limit => 10485760, :null => false
      t.timestamps
    end
  end
end
