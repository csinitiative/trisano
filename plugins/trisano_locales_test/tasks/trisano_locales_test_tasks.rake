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
# task :trisano_locales_test do
#   # Task goes here
# end

def test_db_translations_dir
  File.join(File.dirname(__FILE__), '..', 'config', 'misc')
end

def test_role_translation_files
  %w(test_roles)
end

# locales tests are here, because they rely on test translations
namespace :dev do
  task :load_defaults do
    # Debt: Codes and CSV translations are loaded with an earlier hack; sync when it makes sense
    # Rake::Task['test:load_code_translations'].invoke
    # Rake::Task['test:load_csv_translations'].invoke
    Rake::Task['locales_test:load_role_translations'].invoke
  end

  namespace :feature do
    task :prepare do
      # Debt: Codes and CSV translations are loaded with an earlier hack; sync when it makes sense
      # Rake::Task['test:load_code_translations'].invoke
      # Rake::Task['test:load_csv_translations'].invoke
      Rake::Task['locales_test:load_role_translations'].invoke
    end
  end
end

namespace :locales_test do
  task :spec => [:spec_banner, 'db:test:prepare']
  desc "Runs specs fromt the locales test plugin"
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList[File.join(File.dirname(__FILE__), '..', 'spec')]
  end

  task :spec_banner do
    puts
    puts "*** Running locale tests ***"
  end

  task :load_role_translations do
    puts "Load role translations"
    file_name = test_role_translation_files.join(',')
    file_list = FileList[File.join(test_db_translations_dir, "{#{file_name}}.yml")]
    sh("#{RAILS_ROOT}/script/load_role_translations.rb test #{file_list.join(' ')}")
  end
end

task :spec do |t|
  Rake::Task['locales_test:spec'].invoke
end
