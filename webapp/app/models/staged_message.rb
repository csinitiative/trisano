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

class StagedMessage < ActiveRecord::Base
  before_create :set_state

  validates_presence_of :hl7_message
  validates_length_of :hl7_message, :maximum => 10485760

  def validate
    begin
      hl7
    rescue
      errors.add :hl7_message, "could not be parsed"
    end
    errors.add :hl7_message, "is missing the header" if hl7[:MSH].nil?
  end
  
  def sending_facility
    begin
      hl7[:MSH].sending_facility.split('^').join(' - ')
    rescue
      "Could not be determined"
    end
  end

  def patient_name
    begin
      hl7.select{|s| s.to_s =~ /^PID/}.first.e5.split('^').join(' ')
    rescue
      "Could not be determined"
    end
  end

  def hl7_version
    begin
      hl7[:MSH].version_id
    rescue
      "Could not be determined"
    end
  end
  
  def orders
    hl7.orders
  end

  def hl7
    @hl7 ||= HL7::Message.new(self.hl7_message)
  end

  private

  def set_state
    self.state = "PENDING"
  end

end
