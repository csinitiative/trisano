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
class PopulateAssessmentEventCoreFields < ActiveRecord::Migration
  # We must collect the existing core fields for morbidyt events and then duplicate them for 
  # assessment events
  def self.up
    assessment_core_fields = CoreField.find(:all, :conditions => ["event_type = ?", "assessment_event"])
    
    # We only want to load assessment core fields from morbidity core fields
    # unless they've been defined.
    if assessment_core_fields.empty?

      morbidity_core_fields = CoreField.find(:all, :conditions => ["event_type = ?", "morbidity_event"])

      morbidity_core_fields.each do |field|
        new_field = core_field_to_hash(field)
        new_field['event_type'].gsub!("morbidity", "assessment")
        new_field['key'].gsub!("morbidity", "assessment")
        new_field['parent_key'].gsub!("morbidity", "assessment") unless new_field['parent_key'].nil?

        new_field_formatted = new_field.to_yaml
        new_field_formatted.gsub!("--- \n", "- ")
        new_field_formatted.gsub!("\n", "\n  ")

        CoreField.load!([new_field])
      end
    
    else
      puts "Assessment core fields already defined.  No action taken."
    end
  end

  def self.down
    CoreField.find(:all, :conditions => ["event_type = ?", "assessment_event"]).each do |core_ae|
      core_ae.core_field_translations.each { |cft| cft.destroy }
      core_ae.destroy
    end
  end

  def self.core_field_to_hash(core_field)
    hash = {}
    values = %w(help_text fb_accessible can_follow_up field_type event_type key)
    values.each do |value|
      hash[value.to_s] = core_field.send(value.to_sym)
    end
    return hash
  end

end
