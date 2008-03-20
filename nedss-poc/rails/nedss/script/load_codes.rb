# Codes represented as an array of hashes
codes = YAML::load_file "#{RAILS_ROOT}/db/defaults/codes.yml"

# Can't simply delete all and insert as the delete may trigger a FK constraint
Code.transaction do
  codes.each do |code|
    c = Code.find_or_initialize_by_code_name_and_the_code(:code_name => code['code_name'], 
                                                          :the_code => code['the_code'], 
                                                          :code_description => code['code_description'],
                                                          :sort_order => code['sort_order'])
    c.attributes = code unless c.new_record?
    c.save!
  end
end
