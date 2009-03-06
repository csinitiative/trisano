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

  supports :tasks
  supports :attachments
  
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
    raise "Cannot promote an unsaved contact to a morbidity event" if self.new_record?
    self['type'] = MorbidityEvent.to_s
    self.event_status = "NEW"
    # Pull morb forms
    if self.disease_event && self.disease_event.disease
      jurisdiction = self.jurisdiction ? self.jurisdiction.secondary_entity_id : nil
      self.add_forms(Form.get_published_investigation_forms(self.disease_event.disease_id, jurisdiction, 'morbidity_event'))
    end
    self.add_note("Event changed from contact event to morbidity event")

    if self.save
      self.freeze
      # Return a fresh copy from the db
      MorbidityEvent.find(self.id)
    else
      false
    end
  end
  
end
