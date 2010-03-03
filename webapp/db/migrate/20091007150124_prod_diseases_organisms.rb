class ProdDiseasesOrganisms < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_diseases_organisms.rb #{RAILS_ROOT}/db/defaults/diseases.yml"
    end
  end

  def self.down
  end
end
