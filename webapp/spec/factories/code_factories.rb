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

require 'factory_girl'
require 'faker'

Factory.define(:code) do |code|
  code.code_name  { Factory.next(:code_name) }
  code.the_code   { Factory.next(:the_code)  }
  code.code_description { Factory.next(:code_description) }
end

Factory.define(:external_code) do |code|
  code.code_name  { Factory.next(:code_name) }
  code.the_code   { Factory.next(:the_code)  }
  code.code_description { Factory.next(:code_description) }
end

Factory.define(:contact_type, :parent => :external_code) do |code|
  code.code_name "contact_type"
end

Factory.define(:place_type, :parent => 'code') do |code|
  code.code_name "placetype"
end

Factory.define(:county, :parent => :external_code) do |c|
  c.code_name 'county'
end

Factory.define(:gender, :parent => :external_code) do |g|
  g.code_name 'gender'
end

Factory.define(:treatment_type, :parent => :code) do |g|
  g.code_name 'treatment_type'
end

# sequences

Factory.sequence(:code_name) do |n|
  "code_name_#{n}"
end

Factory.sequence(:the_code) do |n|
  "a#{Time.now.to_i.to_s}#{n}"
end

Factory.sequence(:code_description) do |n|
  "#{n}A code description#{n}"
end

