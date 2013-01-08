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

class ParticipationsContact < ActiveRecord::Base
  has_one :contact_event
  belongs_to :disposition, :class_name => 'ExternalCode'
  belongs_to :contact_type, :class_name => 'ExternalCode'

  validates_presence_of :disposition, 
    :unless => lambda { |pc| pc.disposition_date.blank? }
  
  validates_date :disposition_date, :allow_blank => true,
                                    :on_or_before => lambda { Date.today }
                                   
  def disposition_description
    disposition.code_description unless disposition.nil?
  end

  def contact_type_description
    contact_type.code_description unless contact_type.nil?
  end
end
