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
class PlacesSearchForm

  attr_reader :name, :place_type

  def initialize(params)
    @name = params[:name] || ''
    @place_type = params[:place_type]
  end

  def place_type_options
    Code.placetypes.active.map do |t|
      [t.code_description, t.the_code]
    end
  end

  def participation_type_options
    [
     ["Diagnostic Facility", "DiagnosticFacility"],
     ["Place Exposure", "InterestedPlace"],
     ["Reporting Agency", "ReportingAgency"]
    ]
  end

  def search_type_options
    [[nil, nil]] + (participation_type_options + place_type_options).sort_by(&:first)
  end

  def includes_participation_type?
    participation_types.include?(place_type)
  end

  def includes_place_type?
    not place_type.blank?
  end

  def participation_type
    participation_types_by_value[place_type]
  end

  def participation_types
    participation_type_options.map(&:last) + %w(L H)
  end

  def place_types
    h = Hash["DiagnosticFacility", Place.diagnostic_type_codes,
             "InterestedPlace"   , Place.epi_type_codes,
             "ReportingAgency"   , Place.agency_type_codes]
    h[place_type] || [place_type]
  end

  def participation_types_by_value
    part_types = participation_type_options.map { |n,v| [v,v] }
    part_types << ['L','Lab']
    part_types << ['H', 'HospitalizationFacility']
    Hash[*part_types.flatten]
  end

end
