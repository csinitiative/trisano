class LabResult < ActiveRecord::Base
  belongs_to :specimen_source, :class_name => 'ExternalCode'
  belongs_to :specimen_sent_to_uphl_yn, :class_name => 'ExternalCode'

  belongs_to :participation

  validates_presence_of :lab_result_text 

  validates_date :collection_date, :allow_nil => true
  validates_date :lab_test_date, :allow_nil => true

  def validate
    if !collection_date.blank? && !lab_test_date.blank?
      errors.add(:lab_test_date, "cannot precede collection date") if lab_test_date.to_date < collection_date.to_date
    end
  end
end
