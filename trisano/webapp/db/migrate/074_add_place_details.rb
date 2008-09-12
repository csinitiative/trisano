class AddPlaceDetails < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      transaction do
        say "Loading place exposure code updates"
        [{:code_name => "placetype", :the_code => "S", :code_description => "School", :sort_order => 30},
         {:code_name => "placetype", :the_code => "P", :code_description => "Pool", :sort_order => 35},
         {:code_name => "placetype", :the_code => "FE", :code_description => "Food Establishment", :sort_order => 40},
         {:code_name => "placetype", :the_code => "DC", :code_description => "Daycare", :sort_order => 45},
         {:code_name => "placetype", :the_code => "RA", :code_description => "Recreational Activities", :sort_order => 50},
         {:code_name => "placetype", :the_code => "E", :code_description => "Employer", :sort_order => 55},
         {:code_name => "placetype", :the_code => "CF", :code_description => "Correctional Facility", :sort_order => 60},
         {:code_name => "placetype", :the_code => "LCF", :code_description => "Long-term Care Facility", :sort_order => 65},
         {:code_name => "placetype", :the_code => "GLE", :code_description => "Group Living Environment", :sort_order => 70},
         {:code_name => "participant", :the_code => "PE", :code_description => "Place Exposure", :sort_order => 65},
         {:code_name => "participant", :the_code => "PoI", :code_description => "Place of Interest", :sort_order => 70}
        ].each {|hash| Code.create(hash)}
        say "Updating other"
        code = Code.find_by_code_name_and_code_description("placetype", "Other")
        code.sort_order = 1000
        code.save
      end
    end
  end

  def self.down
  end
end
