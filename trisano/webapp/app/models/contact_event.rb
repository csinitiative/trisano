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

class ContactEvent < HumanEvent
  before_create do |contact|
    contact.add_note("Contact event created.")
  end

  class << self
    def core_views
      [
        ["Demographics", "Demographics"], 
        ["Clinical", "Clinical"], 
        ["Laboratory", "Laboratory"], 
        ["Epidemiological", "Epidemiological"]
      ]
    end
  end

  # If you're wondering why calling #destroy on a contact event isn't deleting the record, this is why.
  # Override destroy to soft-delete record instead.  This makes it easier to work with :autosave.
  def destroy
   self.soft_delete
  end

  def promote_to_morbidity_event
    self['type'] = MorbidityEvent.to_s
    self.event_status = "NEW"
    self.add_note("Event promoted from a contact event")
    # Pull morb forms
    self.freeze if ret = self.save
    ret
  end
end
