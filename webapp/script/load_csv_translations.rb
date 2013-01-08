# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
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
