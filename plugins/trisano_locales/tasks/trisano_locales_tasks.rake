# desc "Explaining what the task does"
# task :trisano_locales do
#   # Task goes here
# end

namespace :trisano do
  namespace :dev do

    desc "Load locale privileges"
    task :load_defaults do
      locale_defaults = File.join(File.dirname(__FILE__), "..", "script", "load_defaults.rb")
      load locale_defaults
    end

    desc "Prep cucumber for default locale changes"
    task :feature_prep => :environment do
      locale_defaults = File.join(File.dirname(__FILE__), "..", "script", "load_defaults.rb")
      load locale_defaults
    end
  end

  namespace :locales do
    task :spec => [:spec_banner, 'db:test:prepare']
    desc "Run specs for the TriSano Locales plugin"
    Spec::Rake::SpecTask.new(:spec) do |t|
      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList[File.join(File.dirname(__FILE__), '..', 'spec')]
    end

    task :spec_banner do
      puts
      puts "*** Running locales specs ***"
    end
  end
end

task :spec do |t|
  Rake::Task['trisano:locales:spec'].invoke
end

