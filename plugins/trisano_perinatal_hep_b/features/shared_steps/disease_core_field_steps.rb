Given /^"([^\"]*)" has disease specific core fields$/ do |disease_name|
  @disease = Disease.find_by_disease_name(disease_name)
  if @disease.core_fields_diseases.empty?
    fields = YAML::load_file(File.join(File.dirname(__FILE__), '../../db/defaults/core_fields.yml'))
    fields.each do |k, hash|
      cf = CoreField.find_by_key(hash['key'])
      cf.core_fields_diseases.build(:disease => @disease, :rendered => true).save!
    end
  end
end
