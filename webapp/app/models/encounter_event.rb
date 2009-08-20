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

class EncounterEvent < HumanEvent
  
  after_create do |encounter|
    parent_event = encounter.parent_event
    encounter.build_disease_event(parent_event.disease_event.attributes) unless parent_event.disease_event.nil?
    encounter.build_jurisdiction(parent_event.jurisdiction.attributes) unless parent_event.jurisdiction.nil?
    encounter.build_interested_party(parent_event.interested_party.attributes) unless parent_event.interested_party.nil?
    encounter.add_note("Encounter event created.")
  end

  class << self
    def core_views
      [
        ["Encounter", "Encounter"],
        ["Clinical", "Clinical"],
        ["Laboratory", "Laboratory"]
      ]
    end
  end

  # If you're wondering why calling #destroy on a contact event isn't deleting the record, this is why.
  # Override destroy to soft-delete record instead.  This makes it easier to work with :autosave.
  def destroy
    self.soft_delete
  end

  private

  def validate
    super

    # Check against birthday only after an interested party has been assigned, which happens after
    # initial creation.  Look up there ^^.
    return if self.interested_party.nil?

    base_errors = {}
    return unless bdate = self.interested_party.person_entity.person.birth_date

    if (date = self.participations_encounter.encounter_date.try(:to_date)) && (date < bdate)
      self.participations_encounter.errors.add(:encounter_date, "cannot be earlier than birth date")
      base_errors['encounter'] = "Encounter date(s) precede birth date"
    end

    unless base_errors.empty?
      base_errors.values.each { |msg| self.errors.add_to_base(msg) }
    end
  end
end
