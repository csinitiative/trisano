# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

# Codes represented as an array of hashes
codes = YAML::load_file "#{RAILS_ROOT}/db/defaults/codes.yml"

# Can't simply delete all and insert as the delete may trigger a FK constraint
Code.transaction do
  codes.each do |code|
    if(code['code_name'] == 'placetype' || 
          code['code_name'] == 'investigation' ||
          code['code_name'] == 'participant' || 
          code['code_name'] == 'locationtype')
      
        c = Code.find_or_initialize_by_code_name_and_the_code(:code_name => code['code_name'], 
                                                              :the_code => code['the_code'], 
                                                              :code_description => code['code_description'],
                                                              :sort_order => code['sort_order'])
    else
        c = ExternalCode.find_or_initialize_by_code_name_and_the_code(:code_name => code['code_name'], 
                                                              :the_code => code['the_code'], 
                                                              :code_description => code['code_description'],
                                                              :sort_order => code['sort_order'])
    end
    c.attributes = code unless c.new_record?
    c.save!
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
codes = YAML::load_file "#{RAILS_ROOT}/db/defaults/test_types.yml"
load_codes(ExternalCode, codes)

codes = YAML::load_file "#{RAILS_ROOT}/db/defaults/lab_interpretations.yml"
load_codes(ExternalCode, codes)
