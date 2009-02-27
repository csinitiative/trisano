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

class HospitalsParticipation < ActiveRecord::Base
  belongs_to :particpations

  validates_date :admission_date, :allow_nil => true
  validates_date :discharge_date, :allow_nil => true
  validates_length_of :medical_record_number, :maximum => 255, :allow_blank => true
  def validate
    if !admission_date.blank? && !discharge_date.blank?
      errors.add(:discharge_date, "cannot precede admission date") if discharge_date.to_date < admission_date.to_date
    end
  end

end
