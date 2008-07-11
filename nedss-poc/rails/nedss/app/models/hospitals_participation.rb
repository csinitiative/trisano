class HospitalsParticipation < ActiveRecord::Base
  belongs_to :particpations

  validates_date :admission_date, :allow_nil => true
  validates_date :discharge_date, :allow_nil => true

  def validate
    if !admission_date.blank? && !discharge_date.blank?
      errors.add(:discharge_date, "cannot precede admission date") if discharge_date.to_date < admission_date.to_date
    end
  end

end
