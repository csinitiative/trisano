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

module Trisano
  module TrisanoPerinatalHepB
    module Models
      module DiseaseSpecificValidation
        hook! "DiseaseSpecificValidation"
        reloadable!

        class << self

          def included(base)
            base.extend(ClassMethods)
          end

        end

        module ClassMethods
          def create_perinatal_hep_b_associations
            validations = YAML::load_file(File.join(File.dirname(__FILE__), '../../../../db/defaults/disease_specific_validations.yml'))
            self.create_associations(validations)
          end
        end
        
      end
    end
  end
end
