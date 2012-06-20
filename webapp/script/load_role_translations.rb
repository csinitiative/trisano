#!/usr/bin/env ruby
unless $0 =~ /runner/
  system("#{File.dirname(__FILE__)}/runner", *ARGV.unshift(__FILE__))
  exit 0
end

locale = ARGV.shift
translations = YAML.load(ARGF)
error_code = 0

Role.transaction do
  translations.each do |r|
    role = Role.find_by_role_name(r['role_name'])
    unless role
      $stderr.puts "Could not find role that matched #{r.inspect}"
      error_code = 1
      next
    end
    role_translation = role.role_translations.build(
      :locale => locale,
      :role_name => r['translated_role_name'],
      :description => r['description']
    )
    unless role_translation.save
      $stderr.puts role_translation.errors.full_messages.join("\n") unless role_translation.errors.full_messages == ["Locale has already been taken"]
      error_code = 1
    end
    print "."
  end
end

puts
exit error_code
