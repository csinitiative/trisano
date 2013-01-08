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

class ParticipationsRiskFactor < ActiveRecord::Base
  belongs_to :participation
  belongs_to :food_handler, :class_name => 'ExternalCode'
  belongs_to :healthcare_worker, :class_name => 'ExternalCode'
  belongs_to :group_living, :class_name => 'ExternalCode'
  belongs_to :day_care_association, :class_name => 'ExternalCode'
  belongs_to :pregnant, :class_name => 'ExternalCode'

  validates_length_of :risk_factors, :maximum => 255, :allow_blank => true
  validates_length_of :occupation, :maximum => 255, :allow_blank => true
  validates_date :pregnancy_due_date, {
    :allow_blank => true
  }

  def xml_fields
    [:occupation,
     [:healthcare_worker_id, {:rel => :yesno}],
     :pregnancy_due_date,
     :risk_factors_notes,
     [:food_handler_id, {:rel => :yesno}],
     [:group_living_id, {:rel => :yesno}],
     [:pregnant_id, {:rel => :yesno}],
     [:day_care_association_id, {:rel => :yesno}],
     :risk_factors]
  end
end
