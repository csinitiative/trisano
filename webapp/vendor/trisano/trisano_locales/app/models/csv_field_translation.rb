class CsvFieldTranslation < ActiveRecord::Base
  reloadable!
  belongs_to :csv_field
end
