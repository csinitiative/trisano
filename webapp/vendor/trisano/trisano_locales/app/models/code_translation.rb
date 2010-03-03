class CodeTranslation < ActiveRecord::Base
  reloadable!
  validates_uniqueness_of :locale, :scope => :code_id

  belongs_to :code
end
