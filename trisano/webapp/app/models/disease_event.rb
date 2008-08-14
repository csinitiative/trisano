# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

class DiseaseEvent < ActiveRecord::Base
  belongs_to :hospitalized, :class_name => 'ExternalCode'
  belongs_to :died, :class_name => 'ExternalCode'

  belongs_to :event
  belongs_to :disease

  validates_date :disease_onset_date, :allow_nil => true
  validates_date :date_diagnosed, :allow_nil => true

  def validate
    if !disease_onset_date.blank? && !date_diagnosed.blank?
      errors.add(:date_diagnosed, "cannot precede onset date") if date_diagnosed.to_date < disease_onset_date.to_date
    end
  end
end
