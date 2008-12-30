class AdditionalPlaceTypes < ActiveRecord::Migration
  def self.up
    if RAILS_ENV =~ /production/
      transaction do
        [{:code_name => 'placetype', :the_code => 'PUB', :code_description => 'Public', :sort_order => '71'},
         {:code_name => 'placetype', :the_code => 'OOS', :code_description => 'Out-of-state Public Health Agency', :sort_order => '73'}
        ].each do |code|
          unless Code.find_by_code_name_and_the_code(code[:code_name], code[:the_code])
            Code.create(code)
          end
        end
      end
    end
  end

  def self.down
  end
end
