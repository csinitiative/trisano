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
      module Place
        hook! "Place"
        reloadable!

        class << self
          def included(base)
            base.class_eval do
              class << self
                def actual_delivery_type_codes
                  %w(H C O)
                end

                def expected_delivery_type_codes
                  %w(H C O)
                end

                def expected_delivery_types
                  place_types(expected_delivery_type_codes)
                end

                def expected_delivery_facilities
                  self.active.types(self.expected_delivery_type_codes)
                end

              end
            end
          end
        end

      end
    end
  end
end
