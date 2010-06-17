Factory.define :core_field do
end

Factory.define :core_fields_disease do |o|
  o.disease { Factory.create(:disease) }
  o.core_field { Factory.create(:core_field) }
end

