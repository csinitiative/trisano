# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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


# desc "Explaining what the task does"
# task :trisano_es do
#   # Task goes here
# end

def db_translations_dir
  File.join(File.dirname(__FILE__), '..', 'config', 'misc')
end

def code_translation_files
  %w(es_codes es_contact_types es_test_results es_test_types)
end

def csv_translation_files
  %w(es_csv_fields es_geocode_csv_fields)
end

def role_translation_files
  %w(es_roles)
end

namespace :db do
  task :load_defaults do
    Rake::Task['es:load_code_translations'].invoke
    Rake::Task['es:load_csv_translations'].invoke
    Rake::Task['es:load_role_translations'].invoke
  end

  namespace :feature do
    task :feature_prep do
      Rake::Task['es:load_code_translations'].invoke
      Rake::Task['es:load_csv_translations'].invoke
      Rake::Task['es:load_role_translations'].invoke
    end
  end
end

namespace :es do
  desc "Run spanish translation specs standalone"
  Spec::Rake::SpecTask.new(:spec => [:spec_banner, 'db:test:prepare']) do |t|
    t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList[File.join(File.dirname(__FILE__), '..', 'spec')]
  end

  task :spec_banner do
    puts
    puts "*** Running es specs ***"
  end

  task :load_code_translations do
    puts "Load code translations"
    file_names = code_translation_files.join(',')
    file_list = FileList[File.join(db_translations_dir, "{#{file_names}}.yml")]
    sh("ruby #{RAILS_ROOT}/script/load_code_translations.rb es #{file_list.join(' ')}")
  end

  task :load_csv_translations do
    puts "Load csv translations"
    file_name = csv_translation_files.join(',')
    file_list = FileList[File.join(db_translations_dir, "{#{file_name}}.yml")]
    sh("ruby #{RAILS_ROOT}/script/load_csv_translations.rb es #{file_list.join(' ')}")
  end

  task :load_role_translations do
    puts "Load role translations"
    file_name = role_translation_files.join(',')
    file_list = FileList[File.join(db_translations_dir, "{#{file_name}}.yml")]
    sh("ruby #{RAILS_ROOT}/script/load_role_translations.rb es #{file_list.join(' ')}")
  end

end

task :spec do |t|
  Rake::Task['es:spec'].invoke
end
