#!/usr/bin/env ruby
unless $0 =~ /runner/
  system("#{File.dirname(__FILE__)}/runner", *ARGV.unshift(__FILE__))
  exit 0
end

locale = ARGV.shift
translations = YAML.load(ARGF)
error_code = 0

Code.transaction do
  translations.each do |t|
    code = Code.find_by_code_name_and_the_code(t['code_name'], t['the_code'])
    code = ExternalCode.find_by_code_name_and_the_code(t['code_name'], t['the_code']) unless code
    unless code
      $stderr.puts "Could not find code that matched #{t.inspect}"
      error_code = 1
      next
    end
    code_translation = code.code_translations.build(:locale => locale, :code_description => t['code_description'])
    unless code_translation.save
      $stderr.puts code_translation.errors.full_messages.join("\n") unless code_translation.errors.full_messages == ["Locale has already been taken"]
      error_code = 1
    end
    print "."
  end
end

puts
exit error_code
