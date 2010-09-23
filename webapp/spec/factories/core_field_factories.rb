Factory.define :core_field do
end

Factory.define :cmr_core_field, :parent => :core_field do |cf|
  cf.event_type :morbidity_event
  cf.key 'morbidity_event[parent_guardian]'
end

Factory.define :core_fields_disease do |o|
  o.disease { Factory.create(:disease) }
  o.core_field { Factory.create(:core_field) }
end

Factory.define :cmr_section_core_field, :parent => :cmr_core_field do |cf|
  cf.key 'morbidity_event[patient_name][section]'
  cf.tree_id { CoreField.next_tree_id }
end

