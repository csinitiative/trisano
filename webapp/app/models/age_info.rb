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
class AgeInfo
  attr_reader :age_at_onset, :age_type_id, :age_type

  class << self
    def create_from_dates(birth_date, current_date)
      return new(nil, nil) unless birth_date && current_date
      age, type = calculate_duration(birth_date, current_date)
      new(age, type)
    end

    def calculate_duration(earlier_date, later_date)
      result = DateDiff.new(later_date, earlier_date).calculate
      case
      when result.years.abs > 0:  [result.years,  age_type(:years) ]
      when result.months.abs > 0: [result.months, age_type(:months)]
      else                        [result.days,   age_type(:days)  ]
      end
    end

    def age_type(type)
      convert = {:years => '0', :months => '1', :weeks => '2', :days => '3', :census => '4', :unknown => '9'}
      ExternalCode.first(:conditions => {
                           :code_name => 'age_type',
                           :the_code => convert[type]},
                         :order => 'live DESC')
    end

  end

  def initialize(age_at_onset, age_type)
    @age_at_onset = age_at_onset
    if age_type.kind_of? Fixnum
      @age_type_id = age_type
      @age_type = ExternalCode.find(age_type)
    else
      @age_type = age_type || self.class.age_type(:unknown)
      @age_type_id = @age_type.id
    end
  end

  def to_s
    if age_at_onset.nil?
      return I18n.translate("not_available") unless age_type
      ""
    else
      description = " #{age_type.code_description}" if age_type
      age_at_onset.to_s + description
    end
  end

  def in_years
    return nil if age_at_onset.nil?
    age_type == self.class.age_type(:years) ?  age_at_onset : 0
  end
end
