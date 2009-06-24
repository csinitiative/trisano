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

class InterestedParty < Participation
  belongs_to :person_entity,  :foreign_key => :primary_entity_id
  after_create :associate_longitudinal_data

  has_one :risk_factor, :foreign_key => :participation_id, :class_name => 'ParticipationsRiskFactor', :order => 'created_at ASC'
  has_many :treatments, :foreign_key => :participation_id, :class_name => 'ParticipationsTreatment', :dependent => :destroy, :order => 'created_at ASC'

  accepts_nested_attributes_for :person_entity
  accepts_nested_attributes_for :risk_factor, :treatments, :allow_destroy => true, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }

  def validate
    if self.person_entity.person.nil?
      errors.add_to_base("No information has been supplied for the interested party.")
    end
  end
  
end
