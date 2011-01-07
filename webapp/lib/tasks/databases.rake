Rake::Task['db:setup'].prerequisites.clear

namespace :db do

  task :setup => ['db:create', 'db:schema:load', 'db:migrate', 'db:seed']

  task :seed do
    # make sure models have a fresh view of the data
    ruby %Q{-S rake db:load_codes_and_defaults RAILS_ENV=#{RAILS_ENV}}
    Rake::Task['db:load_test_and_demo_data'].invoke
  end
  
  ## "Load codes and defauts into database"
  task :load_codes_and_defaults => [:load_codes, :load_defaults]

  ## "Load codes into database"
  task :load_codes => :environment do
    load "#{RAILS_ROOT}/script/load_codes.rb"
  end

  ## "Load defaults into database"
  task :load_defaults => :environment do
    load rakefile_dir("script/load_defaults.rb")
    load "#{RAILS_ROOT}/script/set_default_admin_uid.rb"
    load "#{RAILS_ROOT}/script/load_common_test_types.rb"
    runner rakefile_dir('script/load_loinc_codes.rb'),
           rakefile_dir("db/defaults/loinc_codes_to_common_test_types.csv")
    runner rakefile_dir('script/load_diseases.rb'),
           rakefile_dir("db/defaults/diseases.yml")
    load "#{RAILS_ROOT}/script/load_cdc_export_data.rb"
    load "#{RAILS_ROOT}/script/load_cdc_export_data_for_disease_core.rb"
    load "#{RAILS_ROOT}/script/load_disease_export_statuses.rb"
    load "#{RAILS_ROOT}/script/load_csv_defaults.rb"
  end

  ## "Load test/demo data"
  task :load_test_and_demo_data do
    load "#{RAILS_ROOT}/script/load_test_and_demo_data.rb"
  end

  ## "release bits don't include demo data."
  namespace :release do
    task :reset => ['db:drop', 'db:release:setup']

    task :setup => ['db:create', 'db:schema:load', 'db:migrate', 'db:release:seed']

    task :seed => [:environment] do
      seed_file = File.join(RAILS_ROOT, 'db', 'seeds.rb')
      load(seed_file) if File.exist?(seed_file)
      Rake::Task['db:load_codes_and_defaults'].invoke
    end
  end

  namespace :feature do
    desc "Prep work for feature (cucumber) runs"
    task :prepare => ["db:abort_if_pending_migrations"] do
      Rake::Task['db:feature:clone_structure'].invoke
      RAILS_ENV = "feature"
      Rake::Task[:environment].invoke
      load "#{RAILS_ROOT}/script/load_codes.rb"
      load "#{RAILS_ROOT}/script/load_defaults.rb"
      load "#{RAILS_ROOT}/script/set_default_admin_uid.rb"
      load "#{RAILS_ROOT}/script/load_common_test_types.rb"
      load "#{RAILS_ROOT}/script/load_test_and_demo_data.rb"
    end

    task :clone_structure => ['db:structure:dump', "db:feature:purge"] do
      ar_configs = ActiveRecord::Base.configurations
      ENV['PGHOST'] = ar_configs['feature']['host'] if ar_configs['feature']['host']
      ENV['PGPORT'] = ar_configs['feature']['port'].to_s if ar_configs['feature']['port']
      ENV['PGPASSWORD'] = ar_configs['feature']['password'].to_s if ar_configs['feature']['password']
      `psql -U "#{ar_configs['feature']['username']}" -f #{RAILS_ROOT}/db/#{RAILS_ENV}_structure.sql #{ar_configs['feature']['database']}`
    end

    task :purge => [:environment] do
      ar_configs = ActiveRecord::Base.configurations
      ActiveRecord::Base.clear_active_connections!
      drop_database(ar_configs['feature'])
      create_database(ar_configs['feature'])
    end
  end

  Rake::Task["db:test:prepare"].enhance do
    ruby "-S rake spec:db:fixtures:load FIXTURES=codes,code_translations,external_codes,external_code_translations,privileges RAILS_ENV=test"
  end 
end
