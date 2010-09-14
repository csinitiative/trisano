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

            base.has_one :health_care_provider,
              :foreign_key => "event_id",
              :order => 'created_at ASC',
              :dependent => :destroy

            base.belongs_to :state_manager, {
              :class_name => 'User'
            }

            base.accepts_nested_attributes_for :expected_delivery_facility, {
              :reject_if => proc { |attrs| attrs.nil? || attrs.all? { |k, v| v.blank? } },
              :allow_destroy => true }

            base.accepts_nested_attributes_for :actual_delivery_facility, {
              :reject_if => proc { |attrs| attrs.nil? || attrs.all? { |k, v| v.blank? } },
              :allow_destroy => true }

            base.accepts_nested_attributes_for :health_care_provider, {
              :reject_if => proc { |attrs| attrs.nil? || attrs.all? { |k, v| v.blank? } },
              :allow_destroy => true }

          end
        end

        def prepare_perinatal_hep_b_data
          prepare_expected_delivery_facility
          prepare_actual_delivery_facility
          prepare_health_care_provider
        end

        def prepare_expected_delivery_facility
          edf = self.expected_delivery_facility || self.build_expected_delivery_facility
          pe = edf.place_entity || edf.build_place_entity
          pe.place || pe.build_place
          pe.telephones.build if pe.telephones.empty?
        end

        def prepare_health_care_provider
          hcp = self.health_care_provider || self.build_health_care_provider
          person_entity = hcp.person_entity || hcp.build_person_entity
          person_entity.person || person_entity.build_person
          person_entity.telephones.build if person_entity.telephones.empty?
          person_entity.addresses.build if person_entity.addresses.empty?
        end

        def prepare_actual_delivery_facility
          prepare_actual_delivery_facilities_participation
          adf = self.actual_delivery_facility
          pe = adf.place_entity || adf.build_place_entity
          pe.place || pe.build_place
          pe.telephones.build if pe.telephones.empty?
        end

        def prepare_actual_delivery_facilities_participation
          adf = self.actual_delivery_facility || self.build_actual_delivery_facility
          adf.actual_delivery_facilities_participation || adf.build_actual_delivery_facilities_participation
          adf.actual_delivery_facilities_participation
        end

        def remove_expected_delivery_data
          expected_delivery_facility.place_entity = nil
          save!
        end

        def remove_actual_delivery_data
          actual_delivery_facility.place_entity = nil
          save!
        end

        def valid_actual_delivery_date?
          not actual_delivery_date.nil?
        end

        def actual_delivery_date
          return @actual_delivery_date if @actual_delivery_date
          raw_date = safe_call_chain(:actual_delivery_facility, :actual_delivery_facilities_participation, :actual_delivery_date)
          @actual_delivery_date = parse_date_for_validity(raw_date)
        end

        def actual_delivery_date=(date)
          prepare_actual_delivery_facilities_participation.actual_delivery_date = date
        end

        def parse_date_for_validity(date)
          ValidatesTimeliness::Parser.parse(date, :date)
        end

      end
    end
  end
end
