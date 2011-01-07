begin
  $:.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib')
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "--format pretty -p standard --tags ~@pending"
    t.feature_list = [ENV["FEATURE"]] if ENV["FEATURE"]
  end

  desc "Run the standard features (use FEATURE= to specify a single feature)"
  task :features => ['db:feature:prepare']

  desc "Run enhanced features"
  task :enhanced_features do
    sh "cucumber -p enhanced #{ENV['FEATURE']}"
  end

  desc "Run standard features"
  task :standard_features => [:features]

rescue MissingSourceFile
  puts $!.message
end
