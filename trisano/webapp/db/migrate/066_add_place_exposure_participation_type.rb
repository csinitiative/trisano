class AddPlaceExposureParticipationType < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
        Code.create(:code_name        => 'participant',
                    :the_code         => 'PE',
                    :code_description => 'Place Exposure',
                    :sort_order       => 65)
    end
  end

  def self.down
    Code.find_by_code_description('Place Exposure').destroy if RAILS_ENV == 'production'
  end
end
