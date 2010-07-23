namespace :trisano do

  namespace :dev do
    desc "Load Perinatal Hep B defaults"
    task :load_defaults do
      Rake::Task['trisano:perinatal_hep_b:load_defaults'].invoke
    end

    task :feature_prep => :environment do
      Rake::Task['trisano:perinatal_hep_b:feature_prep'].invoke
    end
  end

  namespace :perinatal_hep_b do

    desc "Run specs for Perinatal Hep B"
    Spec::Rake::SpecTask.new(:spec => [:spec_banner, 'db:test:prepare']) do |t|
      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList[File.join(File.dirname(__FILE__), '..', 'spec')]
    end

    task :spec_banner do
      puts
      puts "*** Running Perinatal Hep B specs ***"
    end

    desc "Perinatal Hep B defaults"
    task :load_defaults => :environment do |t|
      puts "Loading Perinatal Hep B codes"
      sh("#{RAILS_ROOT}/script/runner #{File.join(File.dirname(__FILE__), '..', 'script', 'load_codes.rb')}")
      puts "Loading Perinatal Hep B default data"
      sh("#{RAILS_ROOT}/script/runner #{File.join(File.dirname(__FILE__), '..', 'script', 'load_defaults.rb')}")
      sh("#{RAILS_ROOT}/script/runner 'CoreFieldsDisease.create_perinatal_hep_b_associations'")
      sh("#{RAILS_ROOT}/script/runner 'CsvField.create_perinatal_hep_b_associations'")
      sh("#{RAILS_ROOT}/script/runner 'DiseaseSpecificValidation.create_perinatal_hep_b_associations'")
    end

    task :feature_prep do |t|
      puts "Prepping perinatal hep b default data"
      sh("#{RAILS_ROOT}/script/runner -e test #{File.join(File.dirname(__FILE__), '..', 'script', 'load_codes.rb')}")
      sh("#{RAILS_ROOT}/script/runner -e test #{File.join(File.dirname(__FILE__), '..', 'script', 'load_defaults.rb')}")
    end

  end

end

task :spec do |t|
  Rake::Task['trisano:perinatal_hep_b:spec'].invoke
end
