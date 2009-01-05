#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../vendor/plugins/rspec/lib"))
require 'spec'

# open log file
log = File.new("uat.out",  "w")

# redirect stderr to log file
$stderr = log

Dir["spec/uat/*.rb"].each do |path|
  cmd  = "spec #{path}"
  puts "Launching #{cmd}"
  $stdout.flush
  log.write "#{cmd}\n"  
  output = `#{cmd} 2>&1`
  log.write(output)
  log.flush
end
