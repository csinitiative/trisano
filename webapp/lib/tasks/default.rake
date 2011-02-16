Rake::Task[:default].prerequisites.clear

task :default => "spec"

## Purely experimental. Use at your own risk.
task :forking_tests do
  spec_pid = fork { ruby "-S rake spec 2>&1 log/spec_run.log" }
  features_pid = fork { ruby "-S rake features 2>&1 log/features_run.log" }
  p Process.waitall
end
