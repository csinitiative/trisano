#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../vendor/plugins/rspec/lib"))
require 'spec'

###################################################
# Usage
# run_uats uat1 uat2 uat3 etc
#
###################################################

cmd  = "spec "

ARGV.each do |uat|
  cmd  = "#{cmd} #{uat}"  
end
cmd = "#{cmd} > uat.out"
puts "Launching #{cmd}"
exec(cmd)