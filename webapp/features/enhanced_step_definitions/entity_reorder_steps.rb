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

When /^I move the (.+) "([^\"]*)" (.+)$/ do |entity, name, movement|
  move_entity(entity, name, movement)
end

Then /^the (.+) should be ordered (.+)$/ do |entity_plural, names|
  assert_entity_order(entity_plural, names)
end

Given /^I click the arrows on an empty lab result$/ do
  browser_eval_script %Q{ $j("span:contains('Test type')").closest('li').find('span.top').click(); }
end

def move_entity(entity, name, movement)
  movement = movement.split(' ').last

  if (entity == 'treatment' || entity == 'lab result')
    browser_eval_script %Q{ $j("option:contains('#{name}'):selected").closest('li').find('span.#{movement}').click(); }
  elsif (entity == 'contact' || entity == 'place')
    browser_eval_script %Q{ $j("span:contains('#{name}')").closest('li').find('span.#{movement}').click(); }
  else
    raise
  end
end

def assert_entity_order(entity_plural, names)
  names = names.split(", ")
  
  names.size.times do |index|
    # This is times two because there are hidden elements floating with the LIs.
    # Some more creative jQuerying could possibly elimiate this
    li_index(entity_plural, names, index).to_i.should == 2*(index)
  end
end

def li_index(entity_plural, names, index)
  if (entity_plural == 'treatments' || entity_plural == 'lab results')
    return browser_eval_script %Q{ $j("option:contains('#{names[index]}'):selected").closest('li').index(); }
  elsif (entity_plural == 'contacts' || entity_plural == 'places')
    return browser_eval_script %Q{ $j("span:contains('#{names[index]}')").closest('li').index(); }
  else
    raise
  end
end

