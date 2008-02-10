class Mmwr

  def initialize(epi_dates)
    @epi_dates = epi_dates
    #TODO validation of some sort
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

  # Business rules for assigning MMWR week
  # The first day of any MMWR week is Sunday.  MMWR week numbering is sequential beginning with 1 
  # and incrementing with each week to a maximum of 52 or 53.  MMWR week #1 of an MMWR year is the 
  # first week of the year that has at least four days in the calendar year.  For example, if 
  # January 1 occurs on a Sunday, Monday, Tuesday or Wednesday, the calendar week that includes 
  # January 1 would be MMWR week #1.  If January 1 occurs on a Thursday, Friday, or Saturday, the 
  # calendar week that includes January 1 would be the last MMWR week of the previous 
  # year (#52 or #53).  Because of this rule, December 29, 30, and 31 could potentially 
  # fall into MMWR week #1 of the following MMWR year.   
  def calculation
    
    calc_date = @epi_dates[epi_date_used]
    
    1
  end

end
