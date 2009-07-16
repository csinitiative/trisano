@dry_run = ARGV.shift == "--dry-run"

core_fields = YAML.load(IO.read(RAILS_ROOT + "/db/defaults/core_fields.yml"))

core_fields.collect do |k, v|
  db_record = CoreField.find_by_name_and_event_type(v['name'], v['event_type'])
  if db_record.nil?
    db_record = CoreField.find_by_key(v['key'])
    if db_record.nil?
      CoreField.create(v) unless @dry_run
      "* Created new core field: #{v['event_type']} field named '#{v['name']} with key #{v['key'].gsub('[', '\[').gsub(']', '\]')}"
    else
      db_record.update_attribute(:name, v['name']) unless @dry_run
      "* Renamed #{v['event_type']}: '#{db_record.name}' to '#{v['name']}'"
    end
  elsif v['key'] != db_record.key
    old_key = db_record.key
    message = ""
    message << "* Reset core field #{v['event_type']}:'#{v['name']}' key from #{old_key.gsub('[', '\[').gsub(']', '\]')} to #{v['key'].gsub('[', '\[').gsub(']', '\]')}\n"
    forms = []
    FormElement.find_all_by_core_path(old_key).each do |element|
      forms << "** Updated elements of form #{element.form.name}"
    end    
    unless @dry_run
      CoreField.transaction do
        db_record.update_attribute :key, v['key']
        FormElement.update_all("core_path='#{v['key']}'", "core_path = '#{old_key}'")
      end
    end 
    message << forms.uniq.join("\n")
  end
end.compact.sort.each {|a| puts a}
