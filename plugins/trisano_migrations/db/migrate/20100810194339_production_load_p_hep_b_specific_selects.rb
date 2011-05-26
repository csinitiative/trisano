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

class ProductionLoadPHepBSpecificSelects < ActiveRecord::Migration
  def self.up
    if ENV['UPGRADE']
      ActiveRecord::Base.transaction do
        puts "Checking for the Perinatal Hep B plugin"
        p_hep_b_path = File.join(RAILS_ROOT, 'vendor', 'trisano', 'trisano_perinatal_hep_b')

        if File.exists?(p_hep_b_path)
          puts "Loading Perinatal Hep B codes"
          ExternalCode.load_hep_b_external_codes!

          puts "Loading Perinatal Hep B specific selections"
          DiseaseSpecificSelection.create_perinatal_hep_b_associations
        end
      end
    end
  end

  def self.down
  end
end
