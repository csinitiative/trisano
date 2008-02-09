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

  def calculation
    1
  end

end
