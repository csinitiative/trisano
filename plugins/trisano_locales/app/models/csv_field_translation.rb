class CsvFieldTranslation < ActiveRecord::Base
  reloadable!

  validates_uniqueness_of :locale, :scope => :csv_field_id

  belongs_to :csv_field
end
