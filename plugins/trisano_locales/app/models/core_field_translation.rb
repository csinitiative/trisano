class CoreFieldTranslation < ActiveRecord::Base
  reloadable!

  belongs_to :core_field

  validates_presence_of   :locale
  validates_presence_of   :core_field_id
  validates_uniqueness_of :core_field_id, :scope => :locale
end
