puts "Loading common test types"
begin
  file = File.open("#{RAILS_ROOT}/db/defaults/common_test_types.csv")
  CommonTestType.load_from_csv file.read
rescue
  $stderr.puts "Loading common test types failed"
  $stderr.puts $!.message
else
  puts "Successfully loaded common test types"
end
