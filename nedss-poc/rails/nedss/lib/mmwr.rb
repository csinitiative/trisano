require 'date'
require 'pp'

class Mmwr

  def initialize(epi_dates)
    
    @epi_dates = epi_dates        
    #TODO validation of some sort
    #TODO may want to overload so that you can just give it one date
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
      :unknown
      #TODO raise an error?
    end       
  end
  
  # Creates a DateRange for each MMWR for the year.
  def date_range
    date_ranges = Hash.new()
    calc_date = @epi_dates[epi_date_used]        
    first_day_of_year = calc_date.beginning_of_year    
    first_mmwr_week = year_first_mmwr_week    
    sunday = nil
    saturday = nil
    if first_mmwr_week == :first_week
      sunday = first_day_of_year - first_day_of_year.wday
      saturday = sunday + 6
      date_ranges[1] = MmwrDateRange.new("1", sunday.year, sunday, saturday)
    elsif first_mmwr_week == :second_week
      sunday = (first_day_of_year - first_day_of_year.wday) + 7
      saturday = sunday + 6
      date_ranges[1] = MmwrDateRange.new("1", sunday.year, sunday, saturday)      
    end
          
    count = 1
    until saturday >= DateTime.new(first_day_of_year.year, 12, 31)
      sunday += 7
      saturday += 7
      count += 1
      date_ranges[count] = MmwrDateRange.new(count, sunday.year, sunday, saturday)          
    end
    
    # puts "date_ranges"
    # PP.pp(date_ranges)    

    return date_ranges
  end
  
  # Returns a symbol indicating whether the MMWR week starts the first week
  # of the year or the second.
  def year_first_mmwr_week
    calc_date = @epi_dates[epi_date_used]
    if calc_date.wday <= 3
      return :first_week  
    else     
      return :second_week 
    end
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
  def calculation
    
    calc_date = @epi_dates[epi_date_used]
    
    # find date range calc_date is in
    
    1
  end

end

# Contains details on MMWR Week.
class MmwrDateRange
  
  def initialize(mmwr_week, mmwr_year, start_date, end_date)
    @mmwr_week = mmwr_week
    @mmwr_year = mmwr_year
    @start_date = start_date
    @end_date = end_date
  end
  attr_accessor :mmwr_week, :mmwr_year, :start_date, :end_date
  
end
