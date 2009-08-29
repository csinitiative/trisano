puts "Loading common test types"
begin
  CommonTestType.load_from_csv ARGF.read
rescue
  $stderr.puts "Loading common test types failed"
  $stderr.puts $!.message
else
  puts "Successfully loaded common test types"
end
