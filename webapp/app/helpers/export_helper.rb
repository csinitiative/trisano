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

module ExportHelper

  # Significant Debt: Hard coding all of this for now.  This has to change.

  def get_ibis_health_district(jurisdiction_short_name)
    case jurisdiction_short_name
    when "Bear River" then 1
    when "Central Utah" then 2
    when "Davis County" then 3
    when "Salt Lake Valley" then 4
    when "Southeastern Utah" then 5
    when "Southwest Utah" then 6
    when "Summit County" then 7
    when "Tooele County" then 8
    when "TriCounty" then 9
    when "Utah County" then 10
    when "Wasatch County" then 11
    when "Weber-Morgan" then 12
    when "Utah State" then 99
    when "Out of State" then 99
    when "Unassigned" then 99
    when nil then 99
    end
  end

  def get_ibis_county_code(county)
    case county
    when "BE" then 2
    when "BV" then 1
    when "CA" then 3
    when "CR" then 4
    when "DG" then 5
    when "DU" then 7
    when "DV" then 6
    when "EM" then 8
    when "GA" then 9
    when "GR" then 10
    when "IR" then 11
    when "JU" then 12
    when "KA" then 13
    when "MI" then 14
    when "MO" then 15
    when "OS" then 99
    when "RI" then 17
    when "SJ" then 19
    when "SL" then 18
    when "SM" then 22
    when "SP" then 20
    when "SV" then 21
    when "TL" then 23
    when "UI" then 24
    when "UT" then 25
    when "WA" then 27
    when "WB" then 29
    when "WN" then 28
    when "WS" then 26
    when nil then '.'
    end
  end

  def get_ibis_ethnicity(ethnicity_code)
    return "." if ethnicity_code.blank?
    case ethnicity_code
    when "H" then 1
    when "NH", "O" then 2
    when "UNK" then 9
    else "."
    end
  end

  def get_ibis_status(status_code)
    return "." if status_code.blank?
    case status_code
    when "C"  then 1 
    when "P"  then 2 
    when "S"  then 3
    when "NC" then 4 
    # 'U' should never be in production, but it's leaked into tests
    when "UNK", "U" then 9
    end
  end

  def get_ibis_sex(sex_code)
    return "." if sex_code.blank?
    case sex_code
    when "M" then 1
    when "F" then 2
    when "U" then 9
    else "."
    end
  end

  def get_ibis_race(race_codes)
    case race_codes.size
    when 0
      return "."
    when 1
      race = race_codes.first
      case race
      when "W" then 1
      when "B" then 2
      when "AA", "AK" then 3
      when "A" then 4
      when "H" then 5
      when "UNK" then "."
      end
    when 2
      if race_codes.include?("W") then return 7 end
      if race_codes.include?("B") then return 8 end
      if race_codes.include?("AA") || race_codes.include?("AK") then return 9 end
      if race_codes.include?("A") then return 10 end
      if race_codes.include?("H") then return 11 end
      if race_codes.include?("UNK") then return "." end
    else
      return 6
    end
  end

end
