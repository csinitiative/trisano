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

namespace :trisano do

  namespace :dev do
    desc "Load Spanish translations"
    task :load_defaults do
      Rake::Task['trisano:es:load_code_translations'].invoke
      Rake::Task['trisano:es:load_csv_translations'].invoke
    end

    desc "Prep cukes w/ Spanish translations"
    task :feature_prep do
      Rake::Task['trisano:es:load_code_translations'].invoke
      Rake::Task['trisano:es:load_csv_translations'].invoke
    end

  end

  namespace :es do
    desc "Run specs specific to the spanish plugin"
    Spec::Rake::SpecTask.new(:spec => [:spec_banner, 'db:test:prepare']) do |t|
      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList[File.join(File.dirname(__FILE__), '..', 'spec')]
    end

    task :spec_banner do
      puts
      puts "*** Running es specs ***"
    end

    desc "Load Spanish translations of TriSano codes"
    task :load_code_translations do
      puts "Load code translations"
      file_names = code_translation_files.join(',')
      file_list = FileList[File.join(db_translations_dir, "{#{file_names}}.yml")]
      sh("#{RAILS_ROOT}/script/load_code_translations.rb es #{file_list.join(' ')}")
    end

    desc "Load Spanish translations for csv fields"
    task :load_csv_translations do
      puts "Load csv translations"
      file_name = csv_translation_files.join(',')
      file_list = FileList[File.join(db_translations_dir, "{#{file_name}}.yml")]
      sh("#{RAILS_ROOT}/script/load_csv_translations.rb es #{file_list.join(' ')}")
    end
  end

end

task :spec do |t|
  Rake::Task['trisano:es:spec'].invoke
end
