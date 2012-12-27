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

class PlaceEvent < Event
  has_one :interested_place, :foreign_key => "event_id"
  belongs_to :participations_place

  accepts_nested_attributes_for :interested_place
  accepts_nested_attributes_for :participations_place, :reject_if => :nested_attributes_blank?

  before_create :direct_child_creation_initialization, :add_place_event_creation_note
  
  after_save :set_primary_entity_on_secondary_participations

  class << self
    def core_views
      [
        [I18n.t('core_views.place'), "Place"]
      ]
    end
  end

  # If you're wondering why calling #destroy on a place event isn't deleting the record, this is why.
  # Override destroy to soft-delete record instead.  This makes it easier to work with :autosave.
  def destroy
    self.soft_delete
  end

  def copy_event(new_event, event_components)
    super
    # When we get a story asking for it, this is where we will copy over the place participation: interested_place

    # When we get a story asking for it, this is where we will copy over the (now poorly named) participations_places info to a new event.
    # That is, date_of_exposure
  end

  private

  def add_place_event_creation_note
    self.add_note(I18n.translate("system_notes.place_event_created", :locale => I18n.default_locale))
  end

  def set_primary_entity_on_secondary_participations
    reload
    self.participations.each do |participation|
      if participation.primary_entity_id.nil?
        participation.update_attribute 'primary_entity_id', self.interested_place.try(:place_entity).try(:id)
      end
    end
  end

  def validate
    if self.validate_against_bday && parent_event && participations_place
      base_errors = {}
      return unless bdate = parent_event.interested_party.person_entity.person.birth_date

      if (date = self.participations_place.try(:date_of_exposure).try(:to_date)) && (date < bdate)
        self.participations_place.errors.add(:date_of_exposure, :cannot_precede_birth_date)
        base_errors['epi'] = [:precede_birth_date, {:thing => I18n.t(:exposure)}]
      end

      unless base_errors.empty?
        base_errors.values.each { |msg| self.errors.add(:base, *msg) }
      end
    end
  end
  
end
