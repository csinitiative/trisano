begin
  $:.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib')
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "--format pretty"
  end
  task :features
  task :features_with_prep => ['trisano:dev:feature_prep', 'features']
rescue MissingSourceFile
end
