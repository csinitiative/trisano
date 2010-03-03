module I18nCoreField

  def name
    I18n.t(name_key, :scope => i18n_scope)
  end

  def name_key
    core_path_segments.last
  end

  def i18n_scope
    core_path_segments.unshift('event_fields').slice(0...-1)
  end

  def core_path_segments
    core_path.gsub(']','').split('[')
  end

end
