Factory.define :core_field do
end

Factory.define :cmr_core_field, :parent => :core_field do |cf|
  cf.event_type :morbidity_event
end

Factory.define :core_fields_disease do |o|
  o.disease { Factory.create(:disease) }
  o.core_field { Factory.create(:core_field) }
end

