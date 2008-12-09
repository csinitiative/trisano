class LoadTestTypes < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == "production"
      say "Loading default laboratory test types"
      
      test_types = YAML::load_file("#{RAILS_ROOT}/db/defaults/test_types.yml")
        test_types.each do |test_type|
          ExternalCode.create(:code_name => test_type['code_name'], 
                              :the_code => test_type['the_code'], 
                              :code_description => test_type['code_description'], 
                              :sort_order => test_type['sort_order'], 
                              :live => true)
      end
    end
  end

  def self.down
    if RAILS_ENV == "production"
      transaction do
        ExternalCode.delete_all("code_name = 'lab_test_type'")
      end
    end
  end
end
