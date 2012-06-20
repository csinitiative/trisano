#!/usr/bin/env ruby
unless $0 =~ /runner/
  system("#{File.dirname(__FILE__)}/runner", *ARGV.unshift(__FILE__))
  exit 0
end

locale = ARGV.shift
translations = YAML.load(ARGF).values
error_code = 0

Code.transaction do
  translations.each do |t|
    csv_field = CsvField.first(:conditions => {
                                 :event_type => t['event_type'],
                                 :use_description => t['use_description'],
                                 :export_group => t['export_group']})
    unless csv_field
      $stderr.puts "Could not find csv field that matches #{t.inspect}"
      error_code = 1
      next
    end
    hash = { :locale => locale, :long_name => t['long_name'], :short_name => t['short_name'] }
    csv_translation = csv_field.csv_field_translations.build(hash)
    unless csv_translation.save
      $stderr.puts csv_translation.errors.full_messages.join("\n") unless csv_translation.errors.full_messages == ["Locale has already been taken"]
      error_code = 1
    end
    print "."
  end
end

puts
exit error_code
