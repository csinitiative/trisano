# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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
    encounter.build_disease_event(parent_event.disease_event.attributes) unless parent_event.disease_event.nil?
    encounter.add_note(I18n.translate("system_notes.encounter_event_created", :locale => I18n.default_locale))
  end

  before_update do |encounter|
    encounter.add_note(I18n.translate("system_notes.event_edited", :locale => I18n.default_locale))
  end

  class << self
    def core_views
      [
        [I18n.t('core_views.encounter'), "Encounter"],
        [I18n.t('core_views.clinical'), "Clinical"],
        [I18n.t('core_views.laboratory'), "Laboratory"]
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
    # Put other validations above this comment
    return unless self.validate_against_bday

    super
    base_errors = {}
    return unless bdate = self.interested_party.person_entity.person.birth_date
    if (date = self.participations_encounter.encounter_date.try(:to_date)) && (date < bdate)
      self.participations_encounter.errors.add(:encounter_date, :before_bday)
      base_errors['encounter'] = :before_bday
    end

    unless base_errors.empty?
      base_errors.values.each { |msg| self.errors.add_to_base(msg) }
    end
  end
end
