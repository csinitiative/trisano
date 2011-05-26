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

class TreatmentDataMigration < ActiveRecord::Migration
  def self.up
    ParticipationsTreatment.find_each(:batch_size => 1000) do |pt|
      say "=========== PT: #{pt.id} Name: '#{pt.treatment_name}' ==========="

      if pt.treatment_id.nil? && !pt.treatment_name.blank?
        pt.treatment_name = pt.treatment_name[0...255] if pt.treatment_name.size > 255
        treatment_record = Treatment.find_or_initialize_by_treatment_name(pt.treatment_name.strip)

        if treatment_record.new_record?
          say "  -- Creating a new treatment"
          treatment_record.save!
        else
          say "  -- Treatment exists"
        end

        pt.update_attribute(:treatment_id, treatment_record.id)
      else
        say "  -- Treatment OK as is"
        say "  -- Treatment already associated" if !pt.treatment_id.nil?
        say "  -- Treatment name is blank" if pt.treatment_name.blank?
      end
    end
  end

  def self.down
  end
end
