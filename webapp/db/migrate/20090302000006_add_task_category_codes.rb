# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

class AddTaskCategoryCodes < ActiveRecord::Migration

  def self.up
    if RAILS_ENV =~ /production/
      transaction do
        [{:code_name => 'task_category', :the_code => 'APT', :code_description => 'Appointment', :sort_order => '5'},
          {:code_name => 'task_category', :the_code => 'CB', :code_description => 'Call Back', :sort_order => '10'},
          {:code_name => 'task_category', :the_code => 'TM', :code_description => 'Treatment', :sort_order => '15'}
        ].each do |code|
          unless ExternalCode.find_by_code_name_and_the_code(code[:code_name], code[:the_code])
            ExternalCode.create(code)
          end
        end
      end
    end
  end

  def self.down
  end

end
