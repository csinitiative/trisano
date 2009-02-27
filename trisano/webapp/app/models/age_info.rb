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
class AgeInfo
  attr_reader :age_at_onset, :age_type_id, :age_type

  class << self
    def create_from_dates(birth_date, current_date)
      return new(nil, nil) unless birth_date && current_date
      age, type = calculate_duration(birth_date, current_date)
      new(age, type)
    end

    private
    def calculate_duration(earlier_date, later_date)
      duration = later_date - earlier_date
      case 
      when duration < 28:    [duration.to_i,       ExternalCode.age_type(:days)]
      when duration < 7*8:   [(duration/7).round,  ExternalCode.age_type(:weeks)]
      when duration < 12*30: [(duration/30).round, ExternalCode.age_type(:months)]
      when duration > 365:   [(duration/365).to_i, ExternalCode.age_type(:years)]
      else                   [1,  ExternalCode.age_type(:years)]
      end
    end
  end

  def initialize(age_at_onset, age_type)
    @age_at_onset = age_at_onset
    if age_type.kind_of? Fixnum
      @age_type_id = age_type
      @age_type = ExternalCode.find(age_type)
    else
      @age_type = age_type || ExternalCode.age_type(:unknown)
      @age_type_id = @age_type.id
    end
  end

  def to_s    
    if age_at_onset.nil?
      return "N/A" unless age_type
      ""
    else
      description = " #{age_type.code_description}" if age_type
      age_at_onset.to_s + description
    end
  end

  def in_years
    return nil if age_at_onset.nil?
    age_type == ExternalCode.age_type(:years) ?  age_at_onset : 0
  end
end
