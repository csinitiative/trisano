namespace :db do
  task :load_defaults do
    Rake::Task['perinatal_hep_b:load_defaults'].invoke
  end

  namespace :feature do
    task :prepare => :environment do
      Rake::Task['perinatal_hep_b:feature_prep'].invoke
    end
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

  task :load_defaults => :environment do |t|
    puts "Loading Perinatal Hep B codes"
    $:.unshift File.join(File.dirname(__FILE__), '..', 'script')
    load 'load_codes.rb'
    puts "Loading Perinatal Hep B default data"
    load 'load_defaults.rb'
    CoreFieldsDisease.create_perinatal_hep_b_associations
    CsvField.create_perinatal_hep_b_associations
    DiseaseSpecificValidation.create_perinatal_hep_b_associations
    DiseaseSpecificSelection.create_perinatal_hep_b_associations
    DiseaseSpecificCallback.create_perinatal_hep_b_associations
  end

  task :feature_prep do |t|
    $:.unshift File.join(File.dirname(__FILE__), '..', 'script')
    puts "Prepping perinatal hep b default data"
    load 'load_codes.rb'
    load 'load_defaults.rb'
  end

end

task :spec do |t|
  Rake::Task['perinatal_hep_b:spec'].invoke
end
