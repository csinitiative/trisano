class CoreFieldObserver < ActiveRecord::Observer
  observe :core_field, :core_fields_disease

  def after_save(record)
    CoreField.flush_memoization_cache
  end

end
