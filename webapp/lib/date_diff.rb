

class DateDiff

  Result = Struct.new(:years, :months, :days)

  attr_reader :minuend_date, :subtrahend_date

  def initialize(minuend_date, subtrahend_date)
    @minuend_date = minuend_date
    @subtrahend_date = subtrahend_date
  end

  def calculate
    subtract_days
    subtract_months
    subtract_years
    result.clone
  end

  private

  def subtract_days
    while minuend.days < subtrahend.days
      carry_the_month
    end
    result[:days] = minuend.days - subtrahend.days
  end

  def subtract_months
    carry_the_year if minuend.months < subtrahend.months
    result[:months] = minuend.months - subtrahend.months
  end

  def subtract_years
    result[:years] = minuend.years - subtrahend.years
  end

  def result
    @result ||= Result.new(0, 0, 0)
  end

  def minuend
    @minuend ||= Result.new minuend_date.year, minuend_date.month, minuend_date.mday
  end

  def subtrahend
    @subtrahend ||= Result.new subtrahend_date.year, subtrahend_date.month, subtrahend_date.mday
  end

  def carry_the_month
    minuend.months -= 1
    carry_the_year if minuend.months == 0
    minuend.days += Time.days_in_month(minuend.months, minuend.years)
  end

  def carry_the_year
    minuend.years -= 1
    minuend.months += 12
  end

  def days_in_month
    Time.days_in_month(lesser_date.mon, lesser_date.year)
  end

end
