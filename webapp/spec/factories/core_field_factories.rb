Factory.define :core_field do |cf|
  cf.field_type 'single_line_text'
end

Factory.define :cmr_core_field, :parent => :core_field do |cf|
  cf.event_type :morbidity_event
  cf.key 'morbidity_event[parent_guardian]'
end

Factory.define :core_fields_disease do |o|
  o.disease { Factory.create(:disease) }
  o.core_field { Factory.create(:core_field) }
end

Factory.define :cmr_core_fields_disease, :parent => :core_fields_disease do |cf|
  cf.core_field { Factory.create(:cmr_core_field) }
end

Factory.define :cmr_section_core_field, :parent => :cmr_core_field do |cf|
  cf.key 'morbidity_event[interested_party][person_entity][name_section]'
  cf.tree_id { CoreField.next_tree_id }
  cf.field_type 'section'
end

Factory.define :cmr_section_core_fields_disease, :parent => :cmr_core_fields_disease do |cfd|
  cfd.core_field { Factory.create(:cmr_section_core_field) }
end

