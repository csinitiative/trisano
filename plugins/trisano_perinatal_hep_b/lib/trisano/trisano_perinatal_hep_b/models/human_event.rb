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
      module HumanEvent
        hook! "HumanEvent"
        reloadable!

        class << self
          def included(base)
            base.has_one :expected_delivery_facility,
              :foreign_key => "event_id",
              :order => 'created_at ASC',
              :dependent => :destroy

            base.has_one :actual_delivery_facility,
              :foreign_key => "event_id",
              :order => 'created_at ASC',
              :dependent => :destroy

            base.accepts_nested_attributes_for :expected_delivery_facility, {
              :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } },
              :allow_destroy => true }

            base.accepts_nested_attributes_for :actual_delivery_facility, {
              :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } },
              :allow_destroy => true }

          end
        end

        def prepare_perinatal_hep_b_data
          prepare_expected_delivery_facility
          prepare_actual_delivery_facility
        end

        def prepare_expected_delivery_facility
          edf = self.expected_delivery_facility || self.build_expected_delivery_facility
          pe = edf.place_entity || edf.build_place_entity
          pe.place || pe.build_place
          pe.telephones.build if pe.telephones.empty?
        end

        def prepare_actual_delivery_facility
          adf = self.actual_delivery_facility || self.build_actual_delivery_facility
          adf.actual_delivery_facilities_participation || adf.build_actual_delivery_facilities_participation
          pe = adf.place_entity || adf.build_place_entity
          pe.place || pe.build_place
          pe.telephones.build if pe.telephones.empty?
        end

        def remove_expected_delivery_data
          self.expected_delivery_facility.update_attributes(:place_entity => nil)
        end

        def remove_actual_delivery_data
          self.actual_delivery_facility.update_attributes(:place_entity => nil)
        end

      end
    end
  end
end