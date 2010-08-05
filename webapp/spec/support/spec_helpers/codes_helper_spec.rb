module CodeSpecHelper

  def given_external_codes(code_name, the_codes, options={})
    given_code_name(code_name, true)
    the_codes.each do |the_code|
      code = external_code!(code_name, the_code, options)
      yield(code) if block_given?
    end
  end

  def given_codes(code_name, the_codes)
    given_code_name(code_name, false)
    the_codes.each do |the_code|
      code = code!(code_name, the_code)
      yield(code) if block_given?
    end
  end

  def given_disease_specific_external_codes(disease_name, code_name, the_codes)
    given_code_name(code_name)
    disease = disease!(disease_name)
    given_external_codes(code_name, the_codes, :disease_specific => true) do |code|
      disease.disease_specific_selections.create(:external_code => code, :rendered => true)
    end
    disease
  end

  def given_code_name(code_name, external=true)
    CodeName.delete_all(['code_name = ?', code_name])
    Factory.create(:code_name, :code_name => code_name, :external => external)
  end

  def given_contact_disposition_type_codes_loaded
    contact_disposition_type_attributes.map do |attributes|
      ExternalCode.find_or_create_by_the_code_and_code_name(attributes)
    end
  end

  def given_contact_type_codes_loaded
    contact_type_attributes.map do |attributes|
      ExternalCode.find_or_create_by_the_code_and_code_name(attributes)
    end
  end

  def given_race_codes_loaded
    race_type_attributes.map do |attributes|
      ExternalCode.find_or_create_by_the_code_and_code_name(attributes)
    end
  end

  def contact_disposition_type_attributes
    default_code_attributes.select { |attributes| attributes['code_name'] == 'contactdispositiontype' }
  end

  def contact_type_attributes
    default_code_attributes.select { |attributes| attributes['code_name'] == 'contact_type' }
  end

  def race_type_attributes
    default_code_attributes.select { |attributes| attributes['code_name'] == 'race' }
  end

  def default_code_attributes
    codes = YAML::load_file(File.dirname(__FILE__) + '/../../../vendor/trisano/trisano_en/config/misc/en_codes.yml')
    contact_types = YAML::load_file(File.dirname(__FILE__) + '/../../../vendor/trisano/trisano_en/config/misc/en_contact_types.yml')
    codes + contact_types
  end
end
