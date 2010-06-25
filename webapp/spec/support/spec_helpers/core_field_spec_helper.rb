module CoreFieldSpecHelper

  def given_core_fields_loaded
    file = File.join(File.dirname(__FILE__), '../../../db/defaults/core_fields.yml')
    CoreField.load!(YAML::load_file(file))
  end

end
