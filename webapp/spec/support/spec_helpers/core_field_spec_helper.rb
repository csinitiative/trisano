module CoreFieldSpecHelper

  def given_core_fields_loaded
    CoreField.load!(core_fields)
  end

  def given_cmr_core_tabs_loaded
    cmr_tabs = core_fields.select do |field_attr|
      field_attr['event_type'] == 'morbidity_event' and %w(tab event).include?(field_attr['field_type'])
    end
    CoreField.load! cmr_tabs
  end

  def core_fields
    @yaml_core_fields ||= YAML.load_file(File.join(File.dirname(__FILE__), '../../../db/defaults/core_fields.yml'))
  end

  def hide_morbidity_event_tabs(*tab_names_and_options)
    options = tab_names_and_options.extract_options!
    tab_names_and_options.each do |tab_name|
      tab = CoreField.tab(:morbidity_event, tab_name)
      tab.update_attributes! :rendered_attributes => {
        :rendered => false,
        :disease_id => options[:on_disease].id
      }
    end
  end
end
