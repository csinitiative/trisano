# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

puts "Loading codes (script/loading_codes.rb) from db/defaults/code_names.yml"

# DEBT: this file could use some clean-up. Maybe even move code
# loading into models.

code_names = YAML::load_file "#{RAILS_ROOT}/db/defaults/code_names.yml"
# Hash used by the code loading logic to shortcut external lookup
@quick_external = {}
# Can't simply delete all and insert as the delete may trigger a future FK constraint
CodeName.transaction do
  code_names.each do |code_name|
    c = CodeName.find_or_initialize_by_code_name(:code_name => code_name['code_name'],
      :external => code_name['external'])
    c.attributes = code_name unless c.new_record?
    c.save!

    @quick_external[code_name['code_name']] = code_name['external']
  end
end

# Codes represented as an array of hashes
puts "Loading codes from vendor/trisano/trisano_en/config/misc/en_codes.yml"
codes = YAML::load_file "#{RAILS_ROOT}/vendor/trisano/trisano_en/config/misc/en_codes.yml"

# Can't simply delete all and insert as the delete may trigger a FK constraint
Code.transaction do
  codes.each do |code|
    begin
      if(@quick_external[code['code_name']])
        c = ExternalCode.find_or_initialize_by_code_name_and_the_code(:code_name => code['code_name'],
          :the_code => code['the_code'],
          :code_description => code['code_description'],
          :sort_order => code['sort_order'])
      else
        c = Code.find_or_initialize_by_code_name_and_the_code(:code_name => code['code_name'],
          :the_code => code['the_code'],
          :code_description => code['code_description'],
          :sort_order => code['sort_order'])
      end
      c.attributes = code unless c.new_record?
      c.save!
    rescue
      puts code.inspect
      puts CodeTranslation.all.inspect
      raise
    end
  end
end

# Can't simply delete all and insert as the delete may trigger a FK constraint
def load_codes(model, codes)
  model.transaction do
    codes.each do |code|
      c = model.find_or_initialize_by_code_name_and_the_code(:code_name => code['code_name'],
        :the_code => code['the_code'],
        :code_description => code['code_description'],
        :sort_order => code['sort_order'])
      c.attributes = code unless c.new_record?
      c.save!
    end
  end
end

# Codes that have been added later in the development cycle are in distinct files.  Cutting and pasting for now
puts "Loading codes from vendor/trisano/trisano_en/config/misc/en_test_types.yml"
codes = YAML::load_file "#{RAILS_ROOT}/vendor/trisano/trisano_en/config/misc/en_test_types.yml"
load_codes(ExternalCode, codes)

puts "Loading codes from vendor/trisano/trisano_en/config/misc/en_test_results.yml"
codes = YAML::load_file "#{RAILS_ROOT}/vendor/trisano/trisano_en/config/misc/en_test_results.yml"
load_codes(ExternalCode, codes)

puts "Loading codes from vendor/trisano/trisano_en/config/misc/en_contact_types.yml"
codes = YAML::load_file "#{RAILS_ROOT}/vendor/trisano/trisano_en/config/misc/en_contact_types.yml"
load_codes(ExternalCode, codes)

