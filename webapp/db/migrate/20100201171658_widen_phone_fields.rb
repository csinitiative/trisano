class WidenPhoneFields < ActiveRecord::Migration
  def self.up
    %w(country_code area_code phone_number extension).each do |field|
      change_column :telephones, field, :text
    end
  end

  def self.down
    change_column :telephones,    "country_code",  :limit => 3
    change_column :telephones,    "area_code",     :limit => 3
    change_column :telephones,    "phone_number",  :limit => 7
    change_column :telephones,    "extension",     :limit => 6
  end
end
