module CoreFieldSpecHelper

  def given_core_fields_loaded
    CoreField.load!(core_fields)
  end

  def core_fields
    YAML.load_file(File.join(File.dirname(__FILE__), '../../../db/defaults/core_fields.yml'))
  end

end
