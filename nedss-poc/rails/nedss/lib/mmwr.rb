require 'date'
require 'pp'

class Mmwr

  def initialize(epi_dates)
    
    @epi_dates = epi_dates        
    #TODO validation of some sort
    #TODO may want to overload so that you can just give it one date
    #TODO 1 arg with date 0 arg todays date
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
  
  # Returns the MmwrDateRange that is in range.
  def mmwr_week_range
    calc_date = @epi_dates[epi_date_used]
    
    ranges = date_ranges    
    
    mmwr_date_range = nil
    ranges.sort.each do | k, range | 
      # puts "#{range.to_s} in_range: #{range.in_range(calc_date)}"
      if range.in_range(calc_date)
        mmwr_date_range = range
      end
    end
    
    mmwr_date_range
  end  

  # Returns which epi date was used in calculation
  # Priority :onsetdate, :diagnosisdate, :labresultdate, :firstreportdate   
  def epi_date_used
    if @epi_dates.has_key? :onsetdate
      :onsetdate
    elsif @epi_dates.has_key? :diagnosisdate
      :diagnosisdate
    elsif @epi_dates.has_key? :labresultdate
      :labresultdate
    elsif @epi_dates.has_key? :firstreportdate
      :firstreportdate
    else
      raise ArgumentError, "No known date symbol found in @epi_dates #{@epi_dates}"
    end       
  end
    
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
          
    until saturday >= DateTime.new(first_day_of_year.year, 12, 31)
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
      year = @epi_dates[epi_date_used]
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
  
  private
  
  # Creates a DateRange for each MMWR for the year.
  def date_ranges
    date_ranges = Hash.new()
    calc_date = @epi_dates[epi_date_used]
        
    first_day_of_year = calc_date.beginning_of_year    
    first_mmwr_week = year_first_mmwr_week(calc_date)    
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
    until saturday >= DateTime.new(first_day_of_year.year, 12, 31)
      sunday += 7
      saturday += 7
      count += 1
      date_ranges[count] = MmwrDateRange.new(sunday.year, count, sunday, saturday)          
    end
    
    return date_ranges
  end  
  
  # Returns a MmwrDateRange for the last week of the previous year
  def last_mmwr_week_previous_year
    calc_date = @epi_dates[epi_date_used]
    prev_year = DateTime.new(calc_date.year - 1, 12, 31)
    sunday = prev_year - prev_year.wday
    MmwrDateRange.new(prev_year.year, mmwr_weeks(prev_year), sunday, sunday + 6)      
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
