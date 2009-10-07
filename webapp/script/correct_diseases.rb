#!/usr/bin/env ruby

sed_script = ARGV.first

`sed #{sed_script} #{RAILS_ROOT}/db/defaults/diseases_organisms.yml > #{RAILS_ROOT}/db/defaults/diseases_organisms.new`
if File.size? "#{RAILS_ROOT}/db/defaults/diseases_organisms.new"
  FileUtils.mv("#{RAILS_ROOT}/db/defaults/diseases_organisms.new", "#{RAILS_ROOT}/db/defaults/diseases_organisms.yml")
end

`sed #{sed_script} #{RAILS_ROOT}/db/defaults/diseases.yml > #{RAILS_ROOT}/db/defaults/diseases.new`
if File.size? "#{RAILS_ROOT}/db/defaults/diseases.new"
  FileUtils.mv("#{RAILS_ROOT}/db/defaults/diseases.new", "#{RAILS_ROOT}/db/defaults/diseases.yml")
end

`sed #{sed_script} #{RAILS_ROOT}/db/defaults/disease_to_loinc.csv > #{RAILS_ROOT}/db/defaults/disease_to_loinc.new`
if File.size? "#{RAILS_ROOT}/db/defaults/disease_to_loinc.new"
  FileUtils.mv("#{RAILS_ROOT}/db/defaults/disease_to_loinc.new", "#{RAILS_ROOT}/db/defaults/disease_to_loinc.csv")
end


