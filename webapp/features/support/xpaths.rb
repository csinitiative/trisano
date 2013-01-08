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
def xpath_to xpath_name
  case xpath_name

  when /the morbidity event patient's last name/i
    '/morbidity-event/interested-party-attributes/person-entity-attributes/person-attributes/last-name'

  when /the assessment event patient's last name/i
    '/assessment-event/interested-party-attributes/person-entity-attributes/person-attributes/last-name'

  when /the assessment event first reported to public health date/i
    '/assessment-event/first-reported-PH-date'

  when /the morbidity event first reported to public health date/i
    '/morbidity-event/first-reported-PH-date'

  when /the assignment note/i
    '/routing/note'

  when /the task name/i
    '/task/name'

  when /the task due date/i
    '/task/due-date'

  else
    raise %W{Can't find mapping from "#{xpath_name}" to an xpath.}
  end
end
