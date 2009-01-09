#!/usr/bin/env ruby

# open log file
log = File.new("uat.out",  "w")

# redirect stderr to log file
$stderr = log

results = {}
total_examples = 0
total_fail = 0

Dir["spec/uat/*#{ARGV[0]}.rb"].each do |path|
  cmd  = "spec #{path}"
  puts "Launching #{cmd}"
  $stdout.flush
  log.write "#{cmd}\n"
  output = `#{cmd} 2>&1`
  if (output.match(/(\d+) examples?, (\d+) failures?/))
    results[path] = { "examples" => $1.to_i,
                      "failures" => $2.to_i }
    total_examples += $1.to_i
    total_fail += $2.to_i
    #puts "Examples: #{$1}, Failures: #{$2}"
  end
  log.write(output)
  log.flush
end

printf("%-60s%10s%10s\n", 'Name', 'Examples', 'Failures')
results.keys.each do |test|
  printf("%-60s%10s%10s\n", test, results[test]['examples'], results[test]['failures'])
end

puts ""
printf("%-60s%10s%10s\n", 'Total', total_examples, total_fail)
