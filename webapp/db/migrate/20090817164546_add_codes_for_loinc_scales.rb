class AddCodesForLoincScales < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      code_names = YAML::load_file "#{RAILS_ROOT}/db/defaults/code_names.yml"
      codes = YAML::load_file "#{RAILS_ROOT}/db/defaults/codes.yml"

      CodeName.transaction do
        code_names.select { |code_name| %w(test_result test_status loinc_scale).include?(code_name['code_name']) }.each do |code_name|
          c = CodeName.find_or_initialize_by_code_name(:code_name => code_name['code_name'],
                                                       :description => code_name['description'],
                                                       :external => code_name['external'])
          c.attributes = code_name unless c.new_record?
          c.save!
        end

        codes.select{ |code| code['code_name'] == 'loinc_scale' }.each do |code|
          c = ExternalCode.find_or_initialize_by_the_code_and_code_name(code)
          c.save! if c.new_record?
        end
      end
    end
  end

  def self.down
  end
end
