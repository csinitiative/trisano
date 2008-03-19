# Codes represented as an array of hashes
codes = YAML::load_file "#{RAILS_ROOT}/db/defaults/codes.yml"

# Can't simply delete all and insert as the delete may trigger a FK constraint
Code.transaction do
  codes.each do |code|
    c = Code.find_or_initialize_by_code_name_and_the_code(:code_name => code['code_name'], 
                                                          :the_code => code['the_code'], 
                                                          :code_description => code['code_description'])
    c.attributes = code unless c.new_record?
    c.save!
  end
end

# Diseases are represented as an array of strings

diseases = YAML::load_file "#{RAILS_ROOT}/db/defaults/diseases.yml"
Disease.transaction do
  diseases.each do |disease|
    d = Disease.find_or_initialize_by_disease_name(:disease_name => disease)
    d.save! if d.new_record?
  end
end

# Hospitals are represented as an array of strings

hospitals = YAML::load_file "#{RAILS_ROOT}/db/defaults/hospitals.yml"
Entity.transaction do
  hospitals.each do |hospital|
    hospital_type_id = Code.find_by_code_name_and_the_code("placetype", "H").id
    h = Entity.find(:first, 
                    :include => :places, 
                    :select => "places.name", 
                    :conditions => ["entities.entity_type = 'place' and places.place_type_id = ? and places.name = ?",
                      hospital_type_id, hospital])
    Entity.create(:entity_type => 'place', :place => {:name => hospital, :place_type_id => hospital_type_id}) if h.nil?
  end
end
