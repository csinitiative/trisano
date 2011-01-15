require 'sparrowhawk'

task :war do
  Sparrowhawk::Configuration.new do |config|
    config.other_files = FileList['Rakefile']
    config.environment = ENV['RAILS_ENV'] || 'production'
    config.runtimes = 1..5
    config.war_file = 'trisano.war'
  end.war.build
end
