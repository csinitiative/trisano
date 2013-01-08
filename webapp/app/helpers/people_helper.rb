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

module PeopleHelper
  extensible_helper

  def render_person_name(person)
    <<-END
      <span class="data_last_name">#{h(person.last_name)}</span>,
      <span class="data_first_name">#{h(person.first_name)}</span>
      <span class="data_middle_name">#{h(person.middle_name)}</span>
    END
  end

  def render_address_show(form, person_entity)
    address = person_entity.canonical_address || person_entity.build_canonical_address
    render(:partial => 'people/address_show', :locals => {:f => form, :address => address})
  end
end
