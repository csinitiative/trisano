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

class Lab < Participation
  belongs_to :place_entity, :foreign_key => :secondary_entity_id
  has_many   :lab_results, :foreign_key => :participation_id, :order => 'created_at ASC', :dependent => :destroy

  before_destroy do |lab|
    lab.event.add_note(I18n.translate("system_notes.lab_and_results_deleted", :locale => I18n.default_locale))
  end

  validates_presence_of :place_entity

  accepts_nested_attributes_for :lab_results,
    :allow_destroy => true,
    :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }

  accepts_nested_attributes_for :place_entity,
    :reject_if => proc { |attrs| attrs["place_attributes"].all? { |k, v| v.blank? } }
end
