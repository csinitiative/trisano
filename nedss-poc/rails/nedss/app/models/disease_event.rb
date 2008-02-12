class DiseaseEvent < ActiveRecord::Base
  acts_as_reportable
  belongs_to :hospitalized, :class_name => 'Code'
  belongs_to :died, :class_name => 'Code'
  belongs_to :pregnant, :class_name => 'Code'

  belongs_to :event
  belongs_to :disease

  validates_date :disease_onset_date, :allow_nil => true
  validates_date :date_diagnosed, :allow_nil => true

  def validate
    if !pregnancy_due_date.blank? and pregnant.code_description != "Yes"
      errors.add(:pregnancy_due_date, "Person may not have a due date if not pregnant.")
    end

    if !disease_onset_date.blank? && !date_diagnosed.blank?
      errors.add(:date_diagnosed, "cannot precede onset date") if Chronic.parse(date_diagnosed) < Chronic.parse(disease_onset_date)
    end
  end
end
