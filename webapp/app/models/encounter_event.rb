# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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
    encounter.build_interested_party(parent_event.interested_party.attributes) unless parent_event.interested_party.nil?
    encounter.add_note(I18n.translate("system_notes.encounter_event_created", :locale => I18n.default_locale))
  end

  before_update do |encounter|
    if encounter.changed? or encounter.participations_encounter.try(:changed?)
      encounter.add_note(I18n.translate("system_notes.event_edited", :locale => I18n.default_locale))
    end
  end

  has_one :disease_event, {
    :foreign_key => :event_id,
    :primary_key => :parent_id,
    :readonly => true,
    :autosave => false,
    :validate => false
  }

  has_one :jurisdiction, {
    :foreign_key => :event_id,
    :primary_key => :parent_id,
    :readonly => true,
    :autosave => false,
    :validate => false
  }

  has_many :associated_jurisdictions, {
    :order => "created_at ASC",
    :primary_key => :parent_id,
    :foreign_key => :event_id,
    :readonly => true,
    :autosave => false,
    :validate => false
  }

  # ugh. I dislike all_jurisdictions
  has_many :all_jurisdictions, {
    :order => "created_at ASC",
    :class_name => "Participation",
    :conditions => { :type => ['Jurisdiction', 'AssociatedJurisdiction'] },
    :foreign_key => :event_id,
    :primary_key => :parent_id,
    :readonly => true,
    :autosave => false,
    :validate => false
  }

  class << self

    def core_views
      [
        [I18n.t('core_views.encounter'), "Encounter"],
        [I18n.t('core_views.clinical'), "Clinical"],
        [I18n.t('core_views.laboratory'), "Laboratory"]
      ]
    end
  end

  def self.new_event_from(staged_message, options = {})

    return nil if staged_message.patient.patient_last_name.blank?

    event = EncounterEvent.new
    event.parent_event = options[:event_id] ? MorbidityEvent.find(options[:event_id]) : MorbidityEvent.new_event_from(staged_message, options)
    event.build_participations_encounter
    event.participations_encounter.user_id = User.current_user
    event.participations_encounter.encounter_date = Date.today
    event.participations_encounter.description = "Electronic Laboratory Report"
    event.participations_encounter.encounter_location_type = ParticipationsEncounter.location_type_array.last.last
    event
  end

  # If you're wondering why calling #destroy on a contact event isn't deleting the record, this is why.
  # Override destroy to soft-delete record instead.  This makes it easier to work with :autosave.
  def destroy
    self.soft_delete
  end

  # Encounter investigator is in a different place, so we're going to step on the events investigator
  def investigator
    self.participations_encounter.try(:user)
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

  def validate_associated_records_for_disease_event
  end

  def validate_associated_records_for_jurisdiction
  end

  def validate_associated_records_for_interested_party
  end
end
