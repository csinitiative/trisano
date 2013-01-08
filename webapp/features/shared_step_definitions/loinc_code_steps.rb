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
Given /^I have a loinc code "(.*)" with scale "(.*)"$/ do |loinc_code, scale|
  @scale = CodeName.loinc_scale.external_codes.find_by_code_description(scale)
  @loinc_code = LoincCode.create!(:loinc_code => loinc_code, :scale_id => @scale.id)
end

Given /^the loinc code has the organism "([^\"]*)"$/ do |organism_name|
  @loinc_code.organism = Organism.find_by_organism_name organism_name
  @loinc_code.save!
end

After('@clean_loinc_codes') do
  LoincCode.all.each(&:delete)
end
