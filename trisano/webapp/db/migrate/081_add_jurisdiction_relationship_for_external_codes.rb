class AddJurisdictionRelationshipForExternalCodes < ActiveRecord::Migration
  def self.up
    add_column :external_codes, :jurisdiction_id, :integer
    if RAILS_ENV == 'production'
      transaction do
        execute("UPDATE external_codes SET code_description = 'Grand' where code_name='county' and code_description='GRAND'")
        codes = execute("SELECT * from external_codes where code_name='county' and code_description='Carbon'")
        if codes.size == 0
          ExternalCode.create :code_name => "county", :the_code => "CR", :code_description => "Carbon", :sort_order => 17
        end
        [{:county_name => 'Box Elder',  :health_district => 'Bear River'},
         {:county_name => 'Cache',      :health_district => 'Bear River'},
         {:county_name => 'Rich',       :health_district => 'Bear River'},
         {:county_name => 'Juab',       :health_district => 'Central Utah'},
         {:county_name => 'Millard',    :health_district => 'Central Utah'},
         {:county_name => 'Plute',      :health_district => 'Central Utah'},
         {:county_name => 'Sevier',     :health_district => 'Central Utah'},
         {:county_name => 'Sanpete',    :health_district => 'Central Utah'},
         {:county_name => 'Wayne',      :health_district => 'Central Utah'},
         {:county_name => 'Beaver',     :health_district => 'Southwest Utah'},
         {:county_name => 'Garfield',   :health_district => 'Southwest Utah'},
         {:county_name => 'Iron',       :health_district => 'Southwest Utah'},
         {:county_name => 'Kane',       :health_district => 'Southwest Utah'},
         {:county_name => 'Washington', :health_district => 'Southwest Utah'},
         {:county_name => 'Davis',      :health_district => 'Davis County'},
         {:county_name => 'Salt Lake',  :health_district => 'Salt Lake Valley'},
         {:county_name => 'Carbon',     :health_district => 'Southeastern Utah'},
         {:county_name => 'Emery',      :health_district => 'Southeastern Utah'},
         {:county_name => 'Grand',      :health_district => 'Southeastern Utah'},
         {:county_name => 'San Juan',   :health_district => 'Southeastern Utah'},
         {:county_name => 'Summit',     :health_district => 'Summit County'},
         {:county_name => 'Tooele',     :health_district => 'Tooele County'},
         {:county_name => 'Uintah',     :health_district => 'TriCounty'},
         {:county_name => 'Daggett',    :health_district => 'TriCounty'},
         {:county_name => 'Duchesne',   :health_district => 'TriCounty'},
         {:county_name => 'Utah',       :health_district => 'Utah County'},
         {:county_name => 'Weber',      :health_district => 'Weber-Morgan'},
         {:county_name => 'Morgan',     :health_district => 'Weber-Morgan'}
        ].each do |relationship|
          begin
            code = ExternalCode.find_by_code_name_and_code_description('county', relationship[:county_name])
            place = Place.find_by_place_type_id_and_short_name(Code.jurisdiction_place_type_id, relationship[:health_district])
            raise "Couldn't find jurisdiction #{relationship[:health_district]}" unless place
            code.jurisdiction = place
            code.save!
          rescue Exception => ex
            $stderr.puts("Failed to relate county #{relationship[:county_name]} to jurisdiction #{relationship[:health_district]}")
            raise
          end
        end
      end
    end
  end

  def self.down
    remove_colum :external_codes, :jurisdiction_id
  end
end
