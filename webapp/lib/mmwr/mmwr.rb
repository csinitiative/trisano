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

# Morbidity and Mortality Weekly Report (MMWR) week and year calculations.
class Mmwr

  def self.week(week, opts={})
    opts[:for_year] ||= DateTime.now.year
    ranges = Mmwr.new(DateTime.new(opts[:for_year], 1, 1)).send(:date_ranges)
    Mmwr.new(ranges[week].start_date)
  end

  # Accepts no-arg (defaults to DateTime.now), 1 DateTime, or a Hash of
  # epi date identification symbols and DateTimes.
  def initialize(*args)

    case args.size
    when 0
      t = Time.now
      @epi_date = Date.new(t.year, t.month, t.day)
    when 1
      # could be a Hash or a DateTime
      arg0 = args[0]
      if !arg0.is_a?(Hash) && !arg0.is_a?(Date)
        raise ArgumentError, "Mmwr initialize only handles Hash or Date"
      end

      if arg0.is_a?(Hash)
        @epi_dates = arg0

        if @epi_dates[epi_date_used]
          @epi_date = @epi_dates[epi_date_used]
        elsif
          t = Time.now
          @epi_date = Date.new(t.year, t.month, t.day)
        end

      end

      if arg0.is_a?(Date)
        @epi_date = arg0
      end
    else
      raise ArgumentError, "Mmwr initialize takes 0 or 1 arguments."
    end

    @ranges = date_ranges
  end

  # Business rules for assigning MMWR week
  #
  # The first day of any MMWR week is Sunday.  MMWR week numbering is sequential beginning with 1
  # and incrementing with each week to a maximum of 52 or 53. MMWR week #1 of an MMWR year is the
  # first week of the year that has at least four days in the calendar year.  For example, if
  # January 1 occurs on a Sunday, Monday, Tuesday or Wednesday, the calendar week that includes
  # January 1 would be MMWR week #1. If January 1 occurs on a Thursday, Friday, or Saturday, the
  # calendar week that includes January 1 would be the last MMWR week of the previous
  # year (52 or 53).  Because of this rule, December 29, 30, and 31 could potentially
  # fall into MMWR week #1 of the following MMWR year.
  def mmwr_week
    mmwr_week_range.mmwr_week.to_i
  end

  def mmwr_year
    mmwr_week_range.mmwr_year.to_i
  end

  def epi_dates
    @epi_dates ||= {}
  end

  def -(duration)
    Mmwr.new(@epi_date - duration)
  end

  def +(duration)
    Mmwr.new(@epi_date + duration)
  end

  # Returns the MmwrDateRange that is in range.
  def mmwr_week_range
    mmwr_date_range = nil
    @ranges.sort.each do | k, range |
      #puts "#{range.to_s} epi_date: #{@epi_date} in_range: #{range.in_range(@epi_date)}"
      if range.in_range(@epi_date)
        mmwr_date_range = range
      end
    end

    raise "Unable to find MmwrDateRange for #{@epi_date}" if nil == mmwr_date_range
    mmwr_date_range
  end

  # Returns which epi date was used in calculation
  def epi_date_used
    epi_date_keys.select { |key| epi_dates[key] }.first
  end

  def <=>(other_mmwr)
    result = mmwr_year <=> other_mmwr.mmwr_year
    if result == 0
      mmwr_week <=> other_mmwr.mmwr_week
    else
      result
    end
  end

  def succ
    return Mmwr.new(mmwr_week_range.end_date + 1)
    week_candidate = mmwr_week + 1
    if @ranges[week_candidate]
      Mmwr.week week_candidate
    else
      Mmwr.week(1, :for_year => mmwr_year + 1)
    end
  end

  private

  # Returns the number of MMWR weeks for the given year
  def mmwr_weeks(year)

    first_mmwr_week = year_first_mmwr_week(year)
    first_day_of_year = year.beginning_of_year
    sunday = nil
    saturday = nil
    count = 0

    if first_mmwr_week == :first_week
      sunday = first_day_of_year - first_day_of_year.wday
      saturday = sunday + 6
      count += 1
    elsif first_mmwr_week == :second_week
      sunday = (first_day_of_year - first_day_of_year.wday) + 7
      saturday = sunday + 6
      count += 1
    end

    until saturday >= Date.new(first_day_of_year.year, 12, 31)
      sunday += 7
      saturday += 7
      count += 1
    end

    return count
  end

  # Returns a symbol indicating whether the MMWR week starts the first week
  # of the year or the second.
  def year_first_mmwr_week(*args)
    year = nil
    case args.size
    when 0
      year = @epi_date
    when 1
      year = args[0]
    else
      raise ArgumentError, "This method takes 0 or 1 arguments."
    end

    if year.wday <= 3
      return :first_week
    else
      return :second_week
    end
  end

  # Creates a DateRange for each MMWR for the year.
  def date_ranges
    date_ranges = Hash.new()

    first_day_of_year = @epi_date.beginning_of_year
    first_mmwr_week = year_first_mmwr_week(first_day_of_year)
    sunday = nil
    saturday = nil
    if first_mmwr_week == :first_week
      sunday = first_day_of_year - first_day_of_year.wday
      saturday = sunday + 6
      date_ranges[1] = MmwrDateRange.new(sunday.year, "1", sunday, saturday)
    elsif first_mmwr_week == :second_week
      date_ranges[0] = last_mmwr_week_previous_year
      sunday = (first_day_of_year - first_day_of_year.wday) + 7
      saturday = sunday + 6
      date_ranges[1] = MmwrDateRange.new(sunday.year, "1", sunday, saturday)
    end

    count = 1
    until saturday >= Date.new(first_day_of_year.year, 12, 31)
      sunday += 7
      saturday += 7
      count += 1
      date_ranges[count] = MmwrDateRange.new(sunday.year, count, sunday, saturday)
    end

    return date_ranges
  end

  # Returns a MmwrDateRange for the last week of the previous year
  def last_mmwr_week_previous_year
    prev_year = DateTime.new(@epi_date.year - 1, 12, 31)
    sunday = prev_year - prev_year.wday
    MmwrDateRange.new(prev_year.year, mmwr_weeks(prev_year), sunday, sunday + 6)
  end

  private

  def epi_date_keys
    [:onsetdate, :diagnosisdate, :labresultdate, :firstreportdate, :event_created_date]
  end

end

# Contains details on MMWR Week.
class MmwrDateRange
  attr_accessor :mmwr_year, :mmwr_week, :start_date, :end_date
  def initialize(mmwr_year, mmwr_week, start_date, end_date)
    @mmwr_year = mmwr_year
    @mmwr_week = mmwr_week
    @start_date = start_date
    @end_date = end_date
  end

  # Checks if provided date is in range of start_date and end_date.
  def in_range(calc_date)
    if calc_date >= start_date && calc_date <= end_date
      return true
    else
      return false
    end
  end

  def to_s
    "MMWR Year: #{@mmwr_year} MMWR Week: #{@mmwr_week} Start Date: #{@start_date} End Date #{@end_date}"
  end

end
