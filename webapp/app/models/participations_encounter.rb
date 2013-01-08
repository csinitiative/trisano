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

class ParticipationsEncounter < ActiveRecord::Base
  has_one :encounter_event
  
  # Investigator. Consider some sugar here.
  belongs_to :user

  class << self
    def location_type_array
      [
        [I18n.t('encounter_location_types.clinic'), "clinic"],
        [I18n.t('encounter_location_types.home'), "home"],
        [I18n.t('encounter_location_types.phone'), "phone"],
        [I18n.t('encounter_location_types.school'), "school"],
        [I18n.t('encounter_location_types.work'), "work"],
        [I18n.t('encounter_location_types.other'), "other"]
      ]
    end

    def valid_location_types
      @valid_location_types ||= location_type_array.map { |location_type| location_type.last }
    end
  end

  validates_presence_of :user_id
  validates_presence_of :user, :encounter_location_type
  validates_date :encounter_date, :on_or_before => lambda { Date.today }
  validates_inclusion_of :encounter_location_type, :in => self.valid_location_types, :message => "is not valid"
 
end
