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

class LabResult < ActiveRecord::Base
  belongs_to :specimen_source, :class_name => 'ExternalCode'
  belongs_to :specimen_sent_to_state, :class_name => 'ExternalCode'
  belongs_to :test_result, :class_name => 'ExternalCode'
  belongs_to :participation
  belongs_to :staged_message
  belongs_to :organism
  belongs_to :test_type, :class_name => 'CommonTestType'
  belongs_to :test_status, :class_name => 'ExternalCode'

  before_destroy do |lab_result|
    lab_result.participation.event.add_note("Lab result deleted")
  end

  validates_presence_of :test_type_id
  validates_length_of :result_value, :maximum => 255, :allow_blank => true
  validates_length_of :units, :maximum => 50, :allow_blank => true
  validates_length_of :reference_range, :maximum => 255, :allow_blank => true

  validates_date :collection_date, :allow_nil => true
  validates_date :lab_test_date, :allow_nil => true

  def lab_name
    participation.secondary_entity.place.name unless participation.nil?
  end

  def validate
    if !collection_date.blank? && !lab_test_date.blank?
      errors.add(:lab_test_date, "cannot precede collection date") if lab_test_date.to_date < collection_date.to_date
    end
  end
end
