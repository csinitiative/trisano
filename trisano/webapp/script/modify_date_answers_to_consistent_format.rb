# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

# Capturing the work done during the Iteration 4.6 form cleanup that
# was necessitated by early defects in form builder.
#
# This script can only be run against the 4.5 upgrade dump, against which
# cleanup work was done. It is committed mostly for reference. Restored forms
# were generated locally, exported, and delivered as exports to UT.

p "-- Updating all form builder answers that are dates to a consistent format --"
p "-- Please be patient. This could take a while --"

date_qs = Question.find(:all, :conditions => "data_type = 'date'")

i = 0

date_qs.each do |q|
  Answer.find(:all, :conditions => "question_id = '#{q.id}'").each do |a|
    a.save!
    i = i + 1
  end
end

p "-- Updated #{i.to_s} answers --"


