# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

# Purge event data with extreme prejudice

puts "purging events ..."
ActiveRecord::Base.transaction do
  Telephone.delete_all
  Address.delete_all
  EntitiesLocation.delete_all
  Location.delete_all

  DiseaseEvent.delete_all
  Answer.delete_all
  FormReference.delete_all
  Note.delete_all

  # Keep the Jurisdictions intact!!!
  Place.delete_all("place_type_id != #{Code.jurisdiction_place_type_id} OR place_type_id IS NULL")
  Person.delete_all

  # No model for this join table
  ActiveRecord::Base.connection.execute("DELETE FROM people_races")

  ParticipationsRiskFactor.delete_all
  ParticipationsTreatment.delete_all
  HospitalsParticipation.delete_all
  LabResult.delete_all

  Participation.delete_all

  # Keep the Jurisdictions intact!!!
  Entity.find(:all, :conditions => ["id NOT IN (select entity_id from places)"]).each do |entity|
    entity.destroy
  end

  Event.delete_all
end
puts "success - purge events"

# Put hospitals back
puts "replacing hospitals ..."
hospitals = YAML::load_file "#{RAILS_ROOT}/db/defaults/hospitals.yml"
ActiveRecord::Base.transaction do
  hospital_type_id = Code.find_by_code_name_and_the_code("placetype", "H").id
  hospitals.each do |hospital|
    e = Entity.new
    e.entity_type = 'place'
    e.places.build(:name => hospital, :place_type_id => hospital_type_id)
    e.save
  end
end
puts "success - replace hospitals"

# Reset affected sequences 
# Not resetting sequences that are selectively deleted (e.g., Place, Entity)
puts "resetting sequences ..."
ActiveRecord::Base.connection.select_value("select setval('telephones_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('addresses_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('entities_locations_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('locations_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('disease_events_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('survey_answers_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('form_references_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('notes_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('people_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('participations_risk_factors_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('participations_treatments_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('participation_hospitals_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('lab_results_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('participations_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('events_id_seq', 1)")
ActiveRecord::Base.connection.select_value("select setval('events_record_number_seq', 2009000001)")
puts "success - reset sequences"

