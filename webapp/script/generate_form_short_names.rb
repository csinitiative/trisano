# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

def generate_short_name(name)
  name.strip.gsub(/[\(\)\*\'\,]/, '').gsub(/[- ]/, '_').downcase
end

puts 'Updating form short names'

master_copies = Form.find_all_by_is_template(true)

Form.transaction do
  master_copies.each do |master_copy|
    short_name = generate_short_name(master_copy.name)
    puts "  - Short name generated for #{master_copy.name} is #{short_name}"
    master_copy.short_name = short_name
    master_copy.save(false)

    puts "  - Updating published versions"
    master_copy.published_versions.each do |published_version|
      published_version.short_name = short_name
      published_version.save(false)
    end
  end
end
