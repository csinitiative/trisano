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

class Question < ActiveRecord::Base
  
  belongs_to :question_element, :foreign_key => "form_element_id"
  
  validates_presence_of :question_text
  validates_presence_of :data_type, :unless => :core_data
  validates_presence_of :core_data_attr, :if => :core_data
  validates_length_of :question_text, :maximum => 1000, :allow_blank => true
  validates_length_of :help_text, :maximum => 1000, :allow_blank => true

  def data_type
    read_attribute("data_type").to_sym unless read_attribute("data_type").blank?
  end

end
