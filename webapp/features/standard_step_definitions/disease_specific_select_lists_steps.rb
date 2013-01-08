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
Given /^disease "([^\"]*)" has the disease specific "([^\"]*)" options:$/ do |disease_name, code_name, new_options|
  @disease = disease!(disease_name)
  # code names are inconsistent, so this won't always work
  @code_name = CodeName.find_by_code_name(code_name.downcase.gsub(' ', ''))
  new_options.hashes.each do |code_attr|
    code = @code_name.external_codes.build(code_attr.merge(:disease_specific => true))
    code.save!
    @disease.disease_specific_selections.create(:external_code_id => code.id, :rendered => true)
  end
end

Given /^disease "([^\"]*)" hides these "([^\"]*)" options:$/ do |disease_name, code_name, new_options|
  @disease = disease!(disease_name)
  new_options.hashes.each do |code_attr|
    code = external_code!(code_name.downcase.gsub(' ', ''), code_attr['the_code'], code_attr)
    @disease.disease_specific_selections.create(:external_code_id => code.id, :rendered => false)
  end
end

Then /^I should see all of the default "([^\"]*)" options$/ do |code_name|
  @selections_cache = CodeSelectCache.new
  @selections = @selections_cache.drop_down_selections(code_name.gsub(' ', '').downcase)
  @selections.each do |selection|
    assert_tag(:tag => 'option',
               :content => selection.code_description,
               :parent => { :tag => 'select' })
  end
end
