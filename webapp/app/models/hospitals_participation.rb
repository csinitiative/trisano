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

class HospitalsParticipation < ActiveRecord::Base
  belongs_to :participation
  has_one :answer, :as => :repeater_form_object, :dependent => :destroy

  validates_date :admission_date, :allow_blank => true,
                                  :on_or_before => lambda { Date.today } # Admission date cannot be in the future.

  validates_date :discharge_date, :allow_blank => true,
                                  :on_or_before => lambda { Date.today }, # Discharge date cannot be in the future.
                                  :on_or_after => :admission_date # Cannot be discharged before you were admitted.

  validates_length_of :medical_record_number, :maximum => 255, :allow_blank => true

  def xml_fields
    [:admission_date, :discharge_date, :medical_record_number]
  end

  def hospitalization_facility
    participation
  end
end
