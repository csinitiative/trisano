require 'sparrowhawk/rake_task'

namespace :sparrowhawk do
  desc "War up app using Sparrowhawk"
  Sparrowhawk::RakeTask.new do |task|
    task.runtimes = 1..5
    task.war_file = 'trisano.war'
  end
end
