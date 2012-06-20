module I18nCoreField

  def name
    name = I18n.t(name_key, :scope => i18n_scope)
    if name.is_a?(Hash)
      name = I18n.t(:name, :scope => i18n_scope << name_key)
    end
    name
  end

  def name_key
    core_path_segments.last
  end

  def i18n_scope
    core_path_segments.unshift('event_fields').slice(0...-1)
  end

  def core_path_segments
    core_path.gsub(/\[\d+\]/, '').gsub(']','').split('[')
  end
end
