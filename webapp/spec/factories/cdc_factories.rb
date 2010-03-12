Factory.define :export_name do |en|
end

Factory.define :export_column do |ec|
  ec.export_name { Factory.create(:export_name) }
  ec.type_data 'CORE'
  ec.start_position 1
  ec.length_to_output 1
  ec.table_name 'some_table'
  ec.column_name 'some_column'
  ec.export_column_name 'CDC column'
end

Factory.define :export_conversion_value do |ecv|
  ecv.value_to '<some value>'
end

