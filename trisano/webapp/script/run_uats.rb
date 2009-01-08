#!/usr/bin/env ruby

# open log file
log = File.new("uat.out",  "w")

# redirect stderr to log file
$stderr = log

Dir["spec/uat/*#{ARGV[0]}.rb"].each do |path|
  cmd  = "spec #{path}"
  puts "Launching #{cmd}"
  $stdout.flush
  log.write "#{cmd}\n"
  output = `#{cmd} 2>&1`
  output = 'asdf'
  log.write(output)
  log.flush
end
