Rake::Task[:default].prerequisites.clear

task :default => "spec"
