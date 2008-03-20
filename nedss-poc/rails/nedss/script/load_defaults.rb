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

# Jurisdictions are represented as an array of strings

jurisdictions = YAML::load_file "#{RAILS_ROOT}/db/defaults/jurisdictions.yml"
Entity.transaction do
  jurisdictions.each do |jurisdiction|
    jurisdiction_type_id = Code.find_by_code_name_and_the_code("placetype", "J").id
    j = Entity.find(:first, 
                    :include => :places, 
                    :select => "places.name", 
                    :conditions => ["entities.entity_type = 'place' and places.place_type_id = ? and places.name = ?",
                      jurisdiction_type_id, jurisdiction])
    Entity.create(:entity_type => 'place', :place => {:name => jurisdiction, :place_type_id => jurisdiction_type_id}) if j.nil?
  end
end
