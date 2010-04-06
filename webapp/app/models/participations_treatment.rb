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

class ParticipationsTreatment < ActiveRecord::Base
  belongs_to :participation
  belongs_to :treatment_given_yn, :class_name => 'ExternalCode'

  validates_date :treatment_date, :allow_blank => true,
                                  :on_or_before => lambda { Date.today }

  validates_date :stop_treatment_date, :allow_blank => true,
                                       :on_or_before => lambda { Date.today },
                                       :on_or_after => :treatment_date

  validates_length_of :treatment, :maximum => 255, :allow_blank => true
end
