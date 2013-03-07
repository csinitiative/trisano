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

require 'factory_girl'
require 'faker'

Factory.define :assessment_event do |e|
  e.association :interested_party
  e.jurisdiction { Factory.build(:jurisdiction) }
  e.first_reported_PH_date Date.today - 1.day
end

Factory.define :morbidity_event do |e|
  e.association :interested_party
  e.jurisdiction { Factory.build(:jurisdiction) }
  e.first_reported_PH_date Date.today - 1.day
end

Factory.define :morbidity_event_with_disease, :parent => :morbidity_event do |event|
  event.after_build do |event|
    event.save!
    Factory(:disease_event, :event => event)
    event.save!
    event.reload
  end
end

Factory.define :morbidity_event_with_sensitive_disease, :parent => :morbidity_event do |event|
  event.after_build do |event|
    event.save!
    sensitive_disease = Factory(:disease, :sensitive => true)
    Factory(:disease_event, :event => event, :disease => sensitive_disease)
    event.save!
    event.reload
  end
end

Factory.define :contact_event do |e|
  e.association :interested_party
  e.association :jurisdiction
  e.association :parent_event, :factory => :morbidity_event
  e.association :participations_contact
end

Factory.define :contact_with_disease, :parent => :contact_event do |e|
  e.after_build do |event|
    event.save!
    Factory(:disease_event, :event => event)
    event.save!
    event.reload
  end
end

Factory.define :encounter_event do |e|
  e.association :parent_event, :factory => :morbidity_event
end

Factory.define :place_event do |e|
  e.association :interested_place
  e.association :jurisdiction
  e.association :parent_event, :factory => :morbidity_event

  e.after_build do |event|
    event.save!
    Factory(:disease_event, :event => event)
    event.save!
    event.reload
  end
end

Factory.define :form do |f|
  f.short_name { Factory.next(:short_name) }
  f.name       { Factory.next(:long_name) }
  f.event_type 'contact_event'
  f.disable_auto_assign false
end

Factory.define :form_reference do |fr|
  fr.association :form
end

Factory.define :section_element do |se|
  se.name { Factory.next(:long_name) }
end

Factory.define :person do |p|
  p.last_name { Factory.next(:last_name) }
end

Factory.define :clinician, :parent => :person do |c|
  c.person_type 'clinician'
end

Factory.define :place do |p|
  p.name { Factory.next(:place_name) }
end

Factory.define :person_entity do |pe|
  pe.person { Factory.build(:person) }
  pe.email_addresses { |email_addresses| [email_addresses.association(:email_address)] }
end

Factory.define :email_address do |ea|
  ea.email_address { Factory.next(:email_address) }
  # DEBT: FG ought to be able to figure this out. Review polymorphic
  # ass'ns with FG.
  ea.owner_type 'Entity'
end

Factory.define :place_entity do |pe|
  pe.association :place
end

Factory.define :reporter do |r|
  r.primary_entity { Factory.create(:interested_party).person_entity }
  r.secondary_entity { Factory.create(:person_entity) }
end

Factory.define :interested_party do |ip|
  ip.association :person_entity
  ip.association :risk_factor, :factory => :participations_risk_factor
end

Factory.define :interested_place do |ip|
  ip.association :place_entity
end

Factory.define :participations_risk_factor do |rf|
  rf.occupation { Factory.next(:occupation) }
end

Factory.define :participations_treatment do |pt|
  pt.association :treatment
end

Factory.define :participations_contact do |pc|
  pc.association :contact_type
end

Factory.define :jurisdiction do |j|
  j.place_entity { create_jurisdiction_entity }
end

Factory.define :associated_jurisdiction do |aj|
  aj.place_entity { create_jurisdiction_entity }
end

Factory.define :address do |a|
  a.street_number { Factory.next(:street_number) }
  a.street_name   { Factory.next(:street_name) }
  a.unit_number   { Factory.next(:unit_number) }
  a.postal_code   { Factory.next(:postal_code) }
  a.city          { Factory.next(:city) }
  a.state_id      { ExternalCode.find_by_code_name('state').id }
  a.county_id     { ExternalCode.find_by_code_name('county').id }
end

Factory.define :disease_event do |de|
  de.association :disease
end

Factory.define :disease do |d|
  d.disease_name { Factory.next(:disease_name) }
  d.cdc_code     { Factory.next(:cdc_code) }
end

Factory.define :answer do |a|
  a.question { |q| q.association(:question_single_line_text) }
  a.text_answer { Factory.next(:answer_text) }
end

Factory.define :answer_single_line_text, :class => :answer do |a|
  a.question    { |q| q.association(:question_single_line_text) }
  a.text_answer { Factory.next(:answer_text) }
end

Factory.define :question do |q|
  q.question_text { Factory.next(:question_text) }
  q.short_name    { Factory.next(:short_name) }
  q.data_type     'single_line_text'
end

Factory.define :question_single_line_text, :parent => :question do |q|
  q.data_type 'single_line_text'
end

Factory.define :task do |t|
  t.name { Factory.next(:task_name) }
  t.due_date Date.tomorrow
  t.association :user
end

Factory.define :event_with_task, :parent => :morbidity_event do |event|
  event.after_build do |event|
    Factory(:task, :event => event, :child_task => false)
  end
  event.after_create do |event|
    event.reload
  end
end

Factory.define :note do |n|
  n.note "New note"
end

Factory.define :avr_group do |t|
  t.name { Factory.next(:avr_group_name) }
end

Factory.define :telephone do |t|
  t.country_code "1"
  t.area_code "503"
  t.phone_number "555-3333"
  t.extension "100"
  t.entity { Factory.build(:place_entity) }
end

Factory.define :diagnostic_facility do |df|
  df.place_entity { Factory.build(:diagnostic_facility_entity) }
end

Factory.define :canonical_address, :parent => :address do |a|
end

Factory.define :diagnostic_facility_entity, :class => :place_entity do |dfe|
  dfe.place { Factory.build(:hospital) }
  dfe.association :canonical_address
end

Factory.define :hospital, :class => :place do |h|
  h.place_types { [hospital_place_type] }
  h.name { Factory.next(:place_name) }
end

Factory.define :hospitalization_facility do |hf|
  hf.place_entity { create_hospitalization_facility!("hospital name") }
  hf.hospitals_participation { Factory.build(:hospitals_participation) }
end

Factory.define :hospitalization_facility_entity, :parent => :diagnostic_facility_entity do |fe|
end

Factory.define :hospitals_participation do |hp|
  hp.admission_date Date.today - 5.days
  hp.discharge_date Date.today - 1.days
  hp.hospital_record_number { Factory.next(:hospital_record_number) }
end

Factory.define :attachment do |a|
end

Factory.define :event_queue do |eq|
  eq.queue_name   { Factory.next(:queue_name) }
  eq.jurisdiction { create_jurisdiction_entity }
end

Factory.define :code_name do |cn|
end

#
# Sequences
#

Factory.sequence :last_name do |n|
  "last_name_#{n}"
end

Factory.sequence :place_name do |n|
  "place_name_#{n}"
end

Factory.sequence :street_number do |n|
  "#{n}"
end

Factory.sequence :street_name do |n|
  "street name #{n}"
end

Factory.sequence :unit_number do |n|
  "unit#{n}"
end

Factory.sequence :postal_code do |n|
  "99999-#{n.to_s.rjust(4, '0')[-4..-1]}"
end

Factory.sequence :city do |n|
  "city#{n}"
end
Factory.sequence :email_address do |n|
  # DEBT: Added Time.now to ensure uniqueness because sometimes this ends up repeating and causes duplicate email addresses
  "person#{Time.now.to_i.to_s + n.to_s}@example.com"
end

Factory.sequence :disease_name do |n|
  "The dreaded lurgy #{n}"
end

Factory.sequence :cdc_code do |n|
  "#{50000 + n}"
end

Factory.sequence :occupation do |n|
  "Programmer #{n}"
end

Factory.sequence :question_text do |n|
  "#{n}. #{Faker::Lorem.sentence}?"
end

Factory.sequence :answer_text do |n|
  "#{n}. #{Faker::Lorem.sentence}"
end

Factory.sequence :short_name do |n|
  "#{n}_#{Faker::Lorem.words(1)}"
end

Factory.sequence :long_name do |n|
  "#{Faker::Lorem.words(3)} #{n}"
end

Factory.sequence :task_name do |n|
  "task_name_#{n}"
end

Factory.sequence :avr_group_name do |n|
  "avr_group_name_#{n}"
end

Factory.sequence :treatment_name do |n|
  "Potion Number #{n}"
end

Factory.sequence :queue_name do |n|
  "#{Faker::Lorem.words(1)} #{n}"
end

Factory.sequence :hospital_record_number do |n|
  "1234-#{n}"
end

