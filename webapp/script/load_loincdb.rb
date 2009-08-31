puts "Loading loinc codes"
begin
  LoincCode.load_from_loinctab(ARGF.read) do |row, i|
    $stdout.print '.' if i % 500 == 0
    $stdout.flush
  end
  puts '.'
rescue
  $stderr.puts "Loading loinc codes failed"
  $stderr.puts $!.message
else
  puts "Successfully loaded loinc codes"
end
