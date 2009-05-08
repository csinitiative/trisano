begin
  $:.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib')
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "--format pretty -p standard --tags ~@pending"
    t.step_list = ["features/shared_step_definitions", "features/standard_step_definitions"]
    t.step_pattern = "*.rb"
    t.feature_list = ENV["FEATURE"] ? [ENV["FEATURE"]] : ["features/standard"]
    t.feature_pattern = "*.rb"
  end
  
  desc "Run the standard features (use FEATURE= tp specify a single feature)"
  task :features

  desc "Prep and run standard features"
  task :features_with_prep => ['trisano:dev:feature_prep', 'features']
  
  desc "Run enhanced features"
  task :enhanced_features => ['trisano:dev:enhanced_features']
  
  desc "Run standard features"
  task :standard_features => ['trisano:dev:standard_features']

  desc "Run specs, then prep and run features"
  task :specs_and_features => ['spec', 'trisano:dev:feature_prep', 'features']

rescue MissingSourceFile
end
