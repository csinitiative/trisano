Given /^the following place types:$/ do |table|
  table.hashes.each do |hash|
    unless Code.placetypes.count(:conditions => { :code_description => hash['type'] }) > 0
      Factory.create(:place_type, :code_description => hash['type'])
    end
  end
end

Given /^the following places:$/ do |table|
  table.hashes.each do |hash|
    place = Place.find_by_name(hash['name'])
    unless place
      place_entity = Factory.create(:place_entity)
      place = place_entity.place
      place.update_attributes(:name => hash['name'])
    end
    type = Code.placetypes.find_by_code_description(hash['type'])
    unless place.place_types.exists?(type)
      place.place_types << type
    end
  end
end

Given /^places have these addresses:$/ do |table|
  table.hashes.each do |hash|
    place = Place.find_by_name(hash['place'])
    unless place.entity.canonical_address
      place.entity.create_canonical_address(:street_number => hash['number'], :street_name => hash['street'])
    end
  end
end
