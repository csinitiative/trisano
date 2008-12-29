class ReportingAgencyType < ActiveRecord::Base
  belongs_to :place
  belongs_to :code
end
