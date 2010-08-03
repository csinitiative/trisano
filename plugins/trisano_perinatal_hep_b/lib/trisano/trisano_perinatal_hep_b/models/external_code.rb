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

module Trisano
  module TrisanoPerinatalHepB
    module Models
      module ExternalCode
        hook! "ExternalCode"
        reloadable!

        class << self
          def included(base)
            base.extend(ClassMethods)
          end
        end

        module ClassMethods
          def load_hep_b_external_codes!
            transaction do
              load!(hep_b_external_code_attributes)
            end
          end

          private

          def hep_b_external_code_attributes
            YAML::load_file(File.dirname(__FILE__) + '/../../../../config/misc/en_external_codes.yml')
          end
        end

      end
    end
  end
end

