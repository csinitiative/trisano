# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

When /^I move the (.+) "([^\"]*)" (.+)$/ do |entity, name, movement|
  move_entity(entity, name, movement)
end

Then /^the (.+) should be ordered (.+)$/ do |entity_plural, names|
  assert_entity_order(entity_plural, names)
end

def move_entity(entity, name, movement)
  movement = movement.split(' ').last

  script = case entity
             when 'treatment'
               %Q{ $j("option:contains('#{name}'):selected").closest('li').find('span.#{movement}').click(); }
             when 'contact'
               %Q{ $j("span:contains('#{name}')").closest('li').find('span.#{movement}').click(); }
             when 'place'
               %Q{ $j("span:contains('#{name}')").closest('li').find('span.#{movement}').click(); }
             else raise
           end

  browser_eval_script(script)
end

def assert_entity_order(entity_plural, names)
  names = names.split(", ")

  names.size.times do |index|
    script = case entity_plural
               when 'treatments'
                 %Q{ $j("option:contains('#{names[index]}'):selected").closest('li').index(); }
               when 'contacts'
                 %Q{ $j("span:contains('#{names[index]}')").closest('li').index(); }
               when 'place'
                 %Q{ $j("span:contains('#{names[index]}')").closest('li').index(); }
               else raise
             end

    li_index = browser_eval_script(script)
    # This is times two because there are hidden elements floating with the LIs.
    # Some more creative jQuerying could possibly elimiate this
    li_index.to_i.should == 2*(index)
  end
end

