class ExternalCodeTranslation < ActiveRecord::Base
  reloadable!
  validates_uniqueness_of :locale, :scope => :external_code_id

  belongs_to :external_code
end
